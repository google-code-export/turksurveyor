=begin
The MIT License

Copyright (c) 2010 Adam Kapelner and Dana Chandler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

class AdminController < ApplicationController
  include SurveyMTurk
  
  before_filter :admin_required
  
  def index
    @title = 'All HITs'
    @surveys = Survey.all_current_experimental_version
    @surveys = @surveys.select{|s| s.completed?} if params[:completed]
    @surveys = @surveys.select{|s| s.treatment[:run] == params[:treatment].to_sym} if params[:treatment]
  end

  def completed_hits
    @title = 'Completed HITs'
    @surveys_completed = Survey.all_current_experimental_version_completed
    separate_data_by_treatment(@surveys_completed)
  end

  def comments_page
    @title = 'All Comments'
    @surveys = Survey.all_current_experimental_version_completed
    @surveys = @surveys.select{|s| s.treatment[:run] == params[:treatment].to_sym} if params[:treatment]
  end
  
  def nuke
    if RAILS_ENV == 'development'
      Survey.destroy_all
      SurveyQuestion.destroy_all
      VersionInfo.destroy_all
    else
      flash[:error] = 'You cannot nuke the db on production'
    end
    redirect_to :action => :index
  end 
  
  def versions
    @title = 'Version Information'
    @version_infos = VersionInfo.find(:all)
  end
  
  def update_version_description
    VersionInfo.find(params[:version]).update_attributes(:description => params[:description])
    render :nothing => true #ajax
  end

  def create_new_version_info
    VersionInfo.create(:version => VersionInfo.count + 1)
    redirect_to :action => :versions
  end
  
  def update_survey_notes
    Survey.find(params[:id]).update_attributes(:notes => params[:notes])
    render :nothing => true #ajax
  end

  #add your test worker IDs here
  DEV_WORKERS = []
  def nuke_dev_workers
    dev_workers = Survey.find_all_by_mturk_worker_id(DEV_WORKERS).each{|s| s.destroy}
    flash[:notice] = "nuked #{dev_workers.length} dev workers"
    redirect_to :action => :index
  end
  
  def cleanup_mturk
    flash[:notice] = "Cleaned up #{Survey.cleanup_mturk} HIT(s) from MTurk"
    redirect_to :action => :index
  end
  
  def create_hits
    Survey.create_survey_hit_and_post_it(Survey::Treatments.inject([]){|arr, run| params["n_#{run}"].to_i.times{arr << run}; arr}.sort_by{rand})
    redirect_to :action => :index
  end
  
  def investigate_survey
    @s = Survey.find(params[:id], :include => [:survey_questions, :browser_statuses])
    @actions = (@s.survey_questions + @s.browser_statuses).sort{|b, a| b.created_at <=> a.created_at}.map{|a| a.class == SurveyQuestion ? Survey.question_object_with_respondent_data(a) : a}
    @title = "W#{@s.id}"
  end

  def investigate_worker_tracks
    @bbt = BigBrotherTrack.find_all_by_mturk_worker_id(params[:mturk_worker_id], :include => :big_brother_params)
    render :layout => false
  end
  
  def data_dump
    #only dump the data that is completed
    response.headers['Cache-Control'] = 'max-age=30, must-revalidate'
    send_file DataDump.dump(Survey.all_current_experimental_version_with_abandons, !params[:coded].nil?),
      :type => 'text/plain', :disposition => 'attachment'
  end

  
  #ajax only
  def pay
    s = Survey.find(params[:id])
    #all checks for valid bonus from javascript
    if params[:bonus] and !params[:bonus].strip.blank? and params[:bonus].strip != 'NaN' and params[:bonus].to_f > 0
      mturk_bonus_assignment(s.mturk_assignment_id, s.mturk_worker_id, params[:bonus], SurveyMTurk::DefaultBonusMessageForSurveys)
      s.bonus = params[:bonus] #this won't get saved if it crashes
    end
    mturk_approve_assignment(s.mturk_assignment_id) #it won't get marked as paid if this crashese
    s.paid_at = Time.now
    s.save!
    dispose_hit_on_mturk(s.mturk_hit_id) #we can also delete it on mturk, tidy up    
    render :text => s.pay_status_to_s
  end  

  #ajax only
  def reject
    s = Survey.find(params[:id])
    mturk_reject_assignment(s.mturk_assignment_id, SurveyMTurk::DefaultRejectionFeedback)
    s.update_attributes(:rejected_at => Time.now)
    dispose_hit_on_mturk(s.mturk_hit_id) #we can also delete it on mturk, tidy up    
    render :text => s.pay_status_to_s
  end
  
  #ajax only
  def send_emails_to_workers
    workers = params[:worker_ids].split(',')
    bad_ids = []
    workers.each do |w|
      begin
        mturk_send_emails(params[:subject], params[:body] + "\r\n\r\nWorker: " + w, [w])
      rescue
        bad_ids << w
      end
    end
    render :text => "#{workers.length - bad_ids.length} email(s) sent! #{bad_ids.empty? ? '' : 'Errors: ' + bad_ids.join(', ')}"
  end
  
  def logout
    admin_logout
    redirect_to '/'
  end

  def investigate_attrition
    @title = 'Deserted HITs'
    @surveys = Survey.find(:all, :include => :survey_questions).select{|s| s.expired_and_uncompleted?}.reject{|s| s.did_not_read_directions_yet?}
    @surveys = @surveys.select{|s| s.treatment[:run] == params[:treatment].to_sym} if params[:treatment]
  end

  def buggy_hits
    @title = 'Buggy HITs with duplicate questions'
    @surveys = Survey.find(:all, :include => :survey_questions).select{|s| s.has_duplicate_questions?}
    @surveys = @surveys.select{|s| s.treatment[:run] == params[:treatment].to_sym} if params[:treatment]
  end

  def dashboard
    @title = 'Dashboard'
    @surveys_completed = Survey.all_current_experimental_version_completed
    #kill those that are completed and then kill those that were never started
    @surveys_abandoned = Survey.all_current_experimental_version_with_abandons.reject{|s| @surveys_completed.include?(s)}.reject{|s| s.did_not_read_directions_yet?}
  end

end
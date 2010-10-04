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

require 'uri'

class SurveyorController < ApplicationController
  include SurveyMTurk
  
  def index
    @s = Survey.find(params[:id], :include => :survey_questions)
    
    #if they are disqualified, shoo them away
    if @s.disqualified?
      redirect_to :action => :disqualified
      return      
    end
    
    #if the survey is completed, shoo them away
    if @s.completed?      
      #record the finishing time only once
      redirect_to :action => :survey_completed, :id => @s.id
      return
    end    
    
    @preview = params[:assignmentId] == PreviewAssignmentId
    
    unless @preview
      #record the beginning time only once
      @s.update_attributes(:started_at => Time.now) if @s.started_at.nil?
      #if the worker has completed one already, shoo them away
      if params[:workerId]
        previous_surveys = Survey.find_all_by_mturk_worker_id(params[:workerId])
        if previous_surveys.detect{|s| s.id != @s.id}
          redirect_to :action => :did_a_survey_previously
          return      
        end
      end
          
      #set the worker only if the worker wasn't set previously
      @s.mturk_worker_id = params[:workerId] if @s.mturk_worker_id.nil?
      #check for different worker than expected
      if @s.mturk_worker_id != params[:workerId] and !params[:workerId].blank?
        #we need to move them away
        redirect_to :action => :wrong_user
        return      
      end 
      #always set the assignment!!! This gets around that dumb MTurk bug
      @s.mturk_assignment_id = params[:assignmentId] if params[:assignmentId]
      #and the ip address...
      @s.ip_address = request.remote_ip
      #always save 
      @s.save!

      @q = @s.get_next_question
    end
    
    render :layout => 'survey'
  end

  def read_directions
    return unless request.post?
    s = Survey.find(params[:id])
    s.update_attributes(:read_directions_at => Time.now)
    redirect_to :action => :index, :id => s.id
  end
  
  def one_question_answered
    return unless request.post?
    s = Survey.find(params[:survey_id])

    #now we need to save the fact that they did this question
    #but make sure there is no duplicates which tends to happen for weird network reasons???
    unless SurveyQuestion.find_by_survey_id_and_question_type_and_signature(s.id, params[:question_type], params[:signature])
      SurveyQuestion.create({
        :survey => s,
        :question_type => params[:question_type],
        :signature => params[:signature],
        :responses => URI.unescape(params[:responses])
      })
    end
    
    #serve them the next question or a "you are done" page
    if s.completed?
      redirect_to :action => :survey_completed, :id => s.id
    else
      redirect_to :action => :index, :id => s.id
    end
  end
  
  def survey_completed
    @s = Survey.find(params[:id])
    @s.update_attributes(:finished_at => Time.now) if @s.finished_at.nil?
    render :layout => 'survey'
  end

  def record_focus_or_unfocus
    BrowserStatus.create(:survey_id => params[:survey_id], :status => params[:status])
    render :nothing => true
  end

  #static pages
  def did_a_survey_previously
    render :layout => 'survey'
  end

  def wrong_user
    render :layout => 'survey'
  end

  #not used yet
  def disqualified
    render :layout => 'survey'
  end

end
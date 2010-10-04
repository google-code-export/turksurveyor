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

class Survey < ActiveRecord::Base
  include EncryptionTools
  extend StatisticsTools
  include SurveyCustomization
  extend SurveyMTurk

  has_many :survey_questions
  has_many :browser_statuses
  
  validates_presence_of :version
  validates_presence_of :wage
  validates_presence_of :country
  validates_presence_of :to_be_expired_at

  serialize :treatment
  Survey.partial_updates = false #note to end-user: this is worth a google search to see what it does

  def Survey.create_n_hit_sets(n)
    Treatments.inject([]){|arr, treatment| n.times{arr << treatment}; arr}.sort_by{rand}.each do |treatment|
      Survey.create_survey_hit_and_post_it(treatment)
    end
  end

  #convenience method for creating HIT(s)
  def Survey.create_survey_hit_and_post_it(run)
    s = Survey.create({
      :version => CURRENT_EXPERIMENTAL_VERSION_NO,
      :wage => SurveyMTurk::EXPERIMENTAL_WAGE,
      :country => SurveyMTurk::EXPERIMENTAL_COUNTRY,
      :to_be_expired_at => SurveyMTurk::DEFAULT_SURVEY_HIT_LIFETIME.seconds.from_now,
      :treatment => {}
    })
    #set the run
    s.treatment[:run] = run
    #now we need to take care of subtle text manipulation treatment randomization(s)
    RandomizedTreatments.each do |item, choices_and_probs|
      s.treatment[item] = randomly_sample_one(choices_and_probs.first, choices_and_probs.last)
    end
    mturk_hit = mturk_create_survey_hit(s.id)
    s.mturk_hit_id = mturk_hit[:HITId]
    s.mturk_group_id = mturk_hit[:HITTypeId]
    s.save!
  end

  def get_question_response(signature)
    q = self.survey_questions.detect{|q| q[:signature] == signature}
    q.nil? ? nil : q[:responses]
  end

  def did_not_read_directions_yet?
    self.read_directions_at.nil?
  end

  def question_objects_with_respondent_data
    self.survey_questions.map_with_index{|sq, i| Survey.question_object_with_respondent_data(sq, i)}
  end

  def Survey.question_object_with_respondent_data(sq, i = nil)
    #first find the data
    q = AllQuestions.detect{|q| q[:signature] == sq.signature}
    raise "no question found for signature |#{sq.signature}|" if q.nil?
    #now add the respondent data for convenience
    q[:responses] = sq.responses
    q[:order] = i
    q[:responded_at] = sq.created_at
    q
  end

  def treatment_to_s
    self.treatment.values.inject([]){|arr, treatment| arr << treatment.to_s; arr}.join(' / ')
  end

  def total_time_for_questions_in_sec
    self.survey_questions.empty? ? nil : self.survey_questions.last.created_at - self.read_directions_at
  end
  
  #common db queries
  #, :include => [:survey_questions, :browser_statuses]
  def Survey.all_current_experimental_version
    all = Survey.find(:all, :conditions => {:version => ExperimentalVersionsToShow}).reject{|s| s.expired_and_uncompleted?}
    Survey.assign_batches(all)
  end

  #, :include => :survey_questions
  def Survey.all_current_experimental_version_with_expired
    all = Survey.find(:all, :conditions => {:version => ExperimentalVersionsToShow})
    Survey.assign_batches(all)
  end

  #make sure to take out the buggy ones
  #, :include => [:survey_questions, :browser_statuses]
  def Survey.all_current_experimental_version_with_abandons
    all = Survey.find(:all, :conditions => {:version => ExperimentalVersionsToShow}).reject{|s| s.has_duplicate_questions?}
    Survey.assign_batches(all)
  end

  def Survey.all_current_experimental_version_completed
    all = Survey.all_current_experimental_version.select{|s| s.completed?}
    Survey.assign_batches(all)
  end
    
  #queries that are related to the incremental filling out of a survey and usually invoked at the view level
  def get_next_question
    q = AllQuestions[num_questions_completed]
    render_randomization_texts(q)
    q
  end

  def render_randomization_texts(q)
    return if q[:randomization_text_switches].nil? #i.e., there were no switches to make
    #the fun begins here because there is randomization
    #now we try to find the key(s) in the survey treatment object corresponding
    #to the randomization we need to make
    i = 0
    q[:randomization_text_switches].each do |key, switch|
      #make the necessary replacement(s)
      randomization_level = self.treatment[key]
      #if for some reason this was not specified in the treatment, we need to crash
      if randomization_level.nil?
        raise %Q|randomization "#{randomization_level}" not specified in survey treatment|
      end
      #now the switch can be absolutely anywhere... so we have to make sure to cover
      #every base of where it could be
      q[:question_title] = q[:question_title].gsub(Survey::FillInChars[i], switch[randomization_level]) if q[:question_title]
      q[:question_description] = q[:question_description].gsub(Survey::FillInChars[i], switch[randomization_level]) if q[:question_description]
      q[:question_text] = q[:question_text].gsub(Survey::FillInChars[i], switch[randomization_level])
      q[:response_choices].each do |response|
        text = response.class == Array ? response.first : response
        text.gsub(Survey::FillInChars[i], switch[randomization_level])
      end if q[:response_choices]
      q[:submit_text] = q[:submit_text].gsub(Survey::FillInChars[i], switch[randomization_level]) if q[:submit_text]
      i += 1 #increment the index
    end
  end

  #Survey.find(:all, :include => :survey_questions).map{|s| s.survey_questions.map{|q| q.signature}.uniq.length == s.survey_questions.length ? nil : s.id}.reject{|t| t.nil?}
  def num_questions_completed
    self.survey_questions.reload.length
  end

  def disqualified?
    false #feature not written yet
  end
  
  def num_questions_left
    NumTotalQuestions - self.survey_questions.length
  end  
  
  def completed?
    num_questions_left.zero?
  end
  
  def rejected?
    !self.rejected_at.nil?
  end
  
  def paid?
    !self.paid_at.nil?
  end

  def pay_status_to_s
    if self.paid?
      %Q|<span style="color:green;">#{self.bonus.nil? ? "paid" : "bonus (#{self.bonus})"}</span>|
    elsif self.rejected?
      %Q|<span style="color:red;">rej</span>|
    end
  end
  
  def expired?
    Time.now > self.to_be_expired_at
  end
  
  def expired_and_uncompleted?
    self.expired? and !self.completed?
  end

  def expired_and_unstarted?
    self.expired? and self.did_not_read_directions_yet?
  end

  def has_duplicate_questions?
    num_questions_completed > self.survey_questions.map{|q| q.signature}.uniq.length
  end

  def default_bonus #embellish this method if need be
    SurveyMTurk::DefaultBonus
  end

  #this codes the responses for data dumps
  def Survey.dump_multiple_responses_coded(responses, true_question)
    q = AllQuestions.detect{|q| q[:signature] == true_question[:signature]}
    return 'pass' if q[:question_type] == :imc_check and true_question[:responses] == 'pass'
    code = []
    q[:response_choices].each do |choice|
      not_contained = true
      responses.to_s.split(ResponseDelimiter).each do |response|
        if response == choice
          code << 1
          not_contained = false
        end
#        p "response: #{response} choice: #{choice}"
      end
      code << 0 if not_contained
    end
    code.join('')
  end

  def Survey.dump_single_response_coded(response, true_question)
    q = AllQuestions.detect{|q| q[:signature] == true_question[:signature]}
    return 'pass' if q[:question_type] == :imc_check and true_question[:responses] == 'pass'
    q[:response_choices].each_with_index do |choice, i|
      return i + 1 if response == choice
    end
    'error' #an error has occured
  end

  def Survey.question_is_a_multiple_response_question?(signature)
    [:multiple_of_many, :multiple_of_many_as_boxes].include?(AllQuestions.detect{|q| q[:signature] == signature}[:response_type])
  end

  def Survey.question_is_a_multiple_choice_question?(signature)
    [:one_of_many].include?(AllQuestions.detect{|q| q[:signature] == signature}[:response_type])
  end

  def Survey.question_is_a_free_response_large_question?(signature)
    [:free_response_large].include?(AllQuestions.detect{|q| q[:signature] == signature}[:response_type])
  end
  
  def Survey.cleanup_mturk
    Survey.find(:all).inject(0) do |num_cleaned, s|
      if s.expired? and !s.paid? and !s.rejected?
        begin
          p dispose_hit_on_mturk(s.mturk_hit_id)
          num_cleaned += 1
        rescue => e
          p e
        end
      end
      num_cleaned
    end
  end

  TimeBetweenBatches = 10.minutes #the cron job does not take more than 10 min to create any number of HITs
  attr_accessor :batch
  def Survey.assign_batches(surveys)
    current_batch = 1
    #sort by when it was created
    surveys = surveys.sort{|a, b| a.created_at <=> b.created_at}
    surveys.each_with_index do |s, i|
      if i > 0 and s.created_at - surveys[i - 1].created_at > TimeBetweenBatches
        current_batch += 1
      end
      s.batch = current_batch
    end
  end
end

class Array
  def map_with_index!
   each_with_index do |e, idx| self[idx] = yield(e, idx); end
  end

  def map_with_index(&block)
    dup.map_with_index!(&block)
  end
end

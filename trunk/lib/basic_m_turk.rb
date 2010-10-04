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

require 'ruby-aws'

#a fairly simple wrapper around the ruby aws interface
module BasicMTurk
  
  #are we in dev mode?
  SERVER_DEV = RAILS_ENV == 'development' ? true : false  #should we use our local computer? or our real server?
  MTURK_DEV = RAILS_ENV == 'development' ? true : false   #should we use the sandbox or production with real money?
  
  #Where is the server?
  SERVER = SERVER_DEV ? PersonalInformation::DevServer : PersonalInformation::ProdServer

  #other constants that are useful
  PreviewAssignmentId = 'ASSIGNMENT_ID_NOT_AVAILABLE'
    
  def mturk_attempt_to_authorize_message
    begin
      mturker.availableFunds #run any function and see what happens
      "1"
    rescue Amazon::WebServices::Util::ValidationException => error
      error.message == "AWS.NotAuthorized" ? 'AWS access key / secret key incorrect.' : error.message
    end
  end
  
  def mturk_create_hit(options = {})
    #error handling
    raise "no title given for HIT" unless options[:title]
    raise "no description given for HIT" unless options[:description]
    raise "no keywords given for HIT" unless options[:keywords]
    raise "no duration given for HIT" unless options[:assignment_duration]
    raise "no signature given for HIT" unless options[:signature]
    raise "no auto-approval time given for HIT" unless options[:assignment_auto_approval]
    raise "no wage given for HIT" unless options[:wage]
    raise "no render URL given for HIT" unless options[:render_url]
        
    if options[:country]
      qr = {
             :QualificationTypeId => '00000000000000000071',
             :Comparator => 'EqualTo',
             :LocaleValue => {:Country => options[:country]},
             :RequiredToPreview => true
           }
    end
    
    question =<<-ENDL
      <ExternalQuestion xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2006-07-14/ExternalQuestion.xsd">
        <ExternalURL>http://#{SERVER}#{options[:render_url]}}</ExternalURL>
        <FrameHeight>830</FrameHeight>
      </ExternalQuestion>
    ENDL
    
    # Creating the HIT and loading it into Mechanical Turk, returns it as an object as well
    mturker.createHIT(:Title => options[:title],
                      :Description => options[:description],
                      :Keywords => options[:keywords],
                      :Question => question,
                      :QualificationRequirement => options[:country].nil? ? nil : qr,
                      :Reward => {:Amount => options[:wage], :CurrencyCode => 'USD'},
                      :Signature => options[:signature],
                      :AssignmentDurationInSeconds => options[:assignment_duration],
                      :AutoApprovalDelayInSeconds => options[:assignment_auto_approval],
                      :LifetimeInSeconds => options[:lifetime],
                      :MaxAssignments => 1 )
  end  
  
  def mturk_approve_assignment(assignment_id, feedback = SurveyMTurk::DefaultAcceptanceMessage)
    mturker.ApproveAssignment(:AssignmentId => assignment_id, :RequesterFeedback => feedback)
  end

  def mturk_reject_assignment(assignment_id, feedback = SurveyMTurk::DefaultRejectionFeedback)
    mturker.RejectAssignment(:AssignmentId => assignment_id, :RequesterFeedback => feedback)
  end

  def mturk_bonus_assignment(assignment_id, worker_id, bonus, feedback = SurveyMTurk::DefaultBonusMessage)
    mturker.GrantBonus(:AssignmentId => assignment_id, :WorkerId => worker_id, :BonusAmount => {:Amount => bonus, :CurrencyCode => 'USD'}, :Reason => feedback)
  end

  def delete_hit_on_mturk(hit_id)
    mturker.DisableHIT(:HITId => hit_id)
  end

  def dispose_hit_on_mturk(hit_id)
    mturker.DisposeHIT(:HITId => hit_id)
  end

  def mturk_send_emails(subject, body, worker_ids)
    mturker.NotifyWorkers({
      :Subject => subject,
      :MessageText => body,
      :WorkerId => worker_ids
    })
  end

  private
  def mturker
    @mturk ||= Amazon::WebServices::MechanicalTurkRequester.new({
      :Host => MTURK_DEV ? :Sandbox : :Production,
      :AWSAccessKeyId => PersonalInformation::AwsAccessKeyID,
      :AWSAccessKey => PersonalInformation::AwsSecretKey
    })
  end  
end

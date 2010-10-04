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

module SurveyMTurk
  include BasicMTurk
  
  #hit defaults
  EXPERIMENTAL_WAGE = 0.11
  DefaultBonus = 0.01 #in USD
  EXPERIMENTAL_COUNTRY = 'US'
  DEFAULT_SURVEY_HIT_TITLE = "Take a short 30-question survey --- $#{EXPERIMENTAL_WAGE}USD"
  DEFAULT_SURVEY_HIT_DESCRIPTION = %Q|Answer a few short questions for a survey.|
  DEFAULT_SURVEY_HIT_KEYWORDS = "survey, questionnaire, poll, opinion, study, experiment"
  #time related HIT defualts
  DEFAULT_SURVEY_ASSIGNMENT_DURATION = 60 * 45 # 45min
  DEFAULT_SURVEY_HIT_LIFETIME = 60 * 60 * 6 # 6hr
  DEFAULT_SURVEY_ASSIGNMENT_AUTO_APPROVAL = 60 * 60 * 72 # 72hrs

  #other things to set
  DefaultAcceptanceMessage = 'Thanks for a job well done!'
  DefaultBonusMessage = 'Thanks for a superb job!'
  DefaultRejectionFeedback = "Sorry, you did not take our survey seriously."

  #things to not change
  DEFAULT_SURVEY_HIT_SIGNATURE = "turksurveyor v#{SurveyCustomizationPrivateFooter::TurkSurveyorVersion}"

  def mturk_create_survey_hit(survey_id, options = {})
    options[:title] ||= DEFAULT_SURVEY_HIT_TITLE
    options[:description] ||= DEFAULT_SURVEY_HIT_DESCRIPTION
    options[:keywords] ||= DEFAULT_SURVEY_HIT_KEYWORDS
    options[:assignment_duration] ||= DEFAULT_SURVEY_ASSIGNMENT_DURATION
    options[:lifetime] ||= DEFAULT_SURVEY_HIT_LIFETIME
    options[:signature] ||= DEFAULT_SURVEY_HIT_SIGNATURE
    options[:assignment_auto_approval] ||= DEFAULT_SURVEY_ASSIGNMENT_AUTO_APPROVAL
    #stuff that's more likely to change
    options[:country] = EXPERIMENTAL_COUNTRY
    options[:wage] = EXPERIMENTAL_WAGE
    #for the actual url that hits our server (do not touch)
    options[:render_url] = "/surveyor?id=#{survey_id}"
    #create the hit and return its data
    mturk_create_hit(options)
  end  
end
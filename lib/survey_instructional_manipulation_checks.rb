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

module SurveyInstructionalManipulationChecks
  include SurveyRandomizationSupport 

  #Make sure you include :question_type => :imc_check

  #this is the IMC check #1 from Oppenheimer et al 2009 (p868 top right)
  Oppenheimer99IMC1 = {
    :signature => 'imc_1_oppenheimer_2009',
    :question_type => :imc_check,
    :response_type => :multiple_of_many_as_boxes,
    :question_title => %Q|Sports Participation|,
    :question_description => %Q|Most modern theories of decision making recognize the fact that decisions do not take
      place in a vacuum. Individual preferences and knowledge, along with situational variables can greatly impact
      the decision process. In order to facilitate our research on decision making we are interested in knowing
      certain factors about you, the decision maker. Specifically, we are interested in whether you actually take
      the time to read the directions; if not, then some of our manipulations that rely on changes in the instructions
      will be ineffective. So, in order to demonstrate that you have read the instructions, please ignore the sports
      items below, as well as the continue button. Instead, simply click on the title at the top of this screen
      (i.e., \"sports participation\") to proceed to the next screen. Thank you very much.|,
    :question_text => %Q|Which of these activities do you engage in regularly?<br/> (click on all that apply)|,
    :response_choices => ["skiing", "soccer", "snowboarding", "running", "hockey", "football", "swimming", "tennis", "basketball", "cycling"]
  }

  #change this based on your implementation
  def passed_imc?
    imc_check = question_objects_with_respondent_data.detect{|q| q[:question_type] == :imc_check}
    return nil if imc_check.nil?
    imc_check[:responses] == 'pass' #the only way to pass is to have "pass" as the response
  end
end
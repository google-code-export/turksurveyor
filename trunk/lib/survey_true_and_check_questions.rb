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

module SurveyTrueAndCheckQuestions
  include SurveyRandomizationSupport 
  include SurveyInstructionalManipulationChecks
  
  #all the questions we are going to ask as an array
  TrueQuestions = [
    {#this is the beer question found in Thaler, 1985 and echoed in Oppenheimer et al, 2009
      :signature => 'beer_question_thaler_1985',
      :question_title => "Soda Question",
      :question_description => %Q|You are on the beach on a hot day. For
        the last hour you have been thinking about how much you would enjoy an ice cold
        can of soda. Your companion needs to make a phone call and offers to bring
        back a soda from the only nearby place where drinks are sold, which happens
        to be a #{FillInChars[0]}. Your companion asks how much you are willing
        to pay for the soda and will only buy it if it is below the price you state.|,
      :question_text => %Q|How much are you willing to pay?|,
      :response_type => :free_response_small,
      :other_response_params => {
        :input_max_characters => 5,
        :text_before_free_response => '$',
        :text_underneath_free_response => '(only numbers and the decimal point are allowed)'
      },
      :randomization_text_switches => [
        [
          :place,
          {:run_down => 'run-down grocery store', :fancy => 'fancy resort'}
        ]
      ]
    }
  ]

  #which questions are we going to ask duplicate after the survey is over
  #these reference the indices in the TrueQuestions array, for no check questions,
  #leave this array empty
  CheckQuestionIndices = []
  
end
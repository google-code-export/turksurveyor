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

module SurveyCustomization
  include SurveyRandomizationSupport
  include SurveyDemographicQuestions
  include SurveyNeedForCognitionQuestions
  include SurveyMiscellaneousQuestions
  include SurveyTrueAndCheckQuestions
  include SurveyCustomizationPrivateHeader

  #should we use a separate preview page? 
  #If so, edit the views/surveyor/_preview_hit.rb
  #If not, the preview will render the directions page
  #with an inactive "begin" button  
  UseSeparatePreviewHitPage = false
  
  #should we let the user know how many questions are left?
  #This is taken care of the view by text in the top right corner e.g. "4 / 20 total questions"
  ShowQuestionCounter = false

  #the [unrecommended] title for the survey (nil for none)
  SurveyTitle = nil

  #Do we use the Kapcha anti-satisficing technology for this survey?
  UseKapcha = true
  #Do we want to discourage navigate aways? Each time the user navigates away
  #the text will disappear and re-fade-in from scratch. Warning: this will probably
  #increase attrition
  UseKapchaDiscourageNavigation = false

  #These are question types that are exempt from the Kapcha technology.
  #Not recommended to use unless you have a very good reason since the level of
  #respondent satisficing will vary between these questions and the others
  QuestionTypesExemptFromKapCha = [:demographic, :need_for_cognition, :feedback]

  #where does the exhortative message go?
  #options are :bottom, :top,
  #(set to nil for no message)
  ExhortativeMessageLocation = :top
  #message that user sees if we exhort them
  ExhortativeMessage = "Please answer carefully. Your responses will be used for research."

  #randomization parameters
  #
  #each thing we randomize on is a key-value pair in this hash
  #the key is its name, the value is a doublet array, the first element
  #is an array with the choices, the second array is their corresponding
  #probabilities which must add up to one. Make sure you place
  #fillers in the question parameters using FillInChars[0], FillInChars[1], etc.
  #for each and every random switch
  RandomizedTreatments = {
    :place => [[:run_down, :fancy], [0.5, 0.5]] #for soda question
  }

  #order of questions in survey
  SurveyOrder = [
    TrueQuestions,
    Oppenheimer99IMC1,
    CheckQuestions,
    DemographicQuestions,
    FeedbackQuestion
  ]

  #constants that deal with experimental versions
  CURRENT_EXPERIMENTAL_VERSION_NO = 1
  ExperimentalVersionsToShow = [1]

  #experimental treatments --- only use this if you are running experiments
  #looking for differential effects between presentation methods. If you are
  #not, leave this as just [:regular]
  Treatments = [:regular]
  #Special text to be shown on directions page for each text
  TreatmentDirectionText = {
    :regular => "Please take the time to carefully read the instructions for each question and to give an accurate and honest answer."
  }

  include SurveyCustomizationPrivateFooter
end
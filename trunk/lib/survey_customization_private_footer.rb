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

module SurveyCustomizationPrivateFooter

  NumTrueQuestions = SurveyCustomization::TrueQuestions.length
  NumCheckQuestions = SurveyCustomization::CheckQuestionIndices.length

  #defaults
  NoOpinionDefault = false
  RandomizeOrderDefault = false
  LikertMinScoreDefault = 1
  LikertMaxScoreDefault = 7
  InputMaxCharactersDefault = 20
  TextareaWidthDefault = 400
  TextareaHeightDefault = 200
  NeedsResponseDefault = true
  DefaultSubmitText = "Continue"
  #Words per minute (WPM) for questions displayed utilizing the KapCha anti-satisficing
  #technology. The default of 250 was chosen from Taylor, 1965's study of average
  #reading speeds where this is the average for a high school student
  KapChaWordsPerMinute = 250

  ResponseDelimiter = ';;;;;;'
  
  AllQuestions = SurveyCustomization::SurveyOrder.flatten
  NumTotalQuestions = AllQuestions.length

  #make sure each at least have {} for the other responses
  AllQuestions.each{|q| q[:other_response_params] ||= {}}

  def Survey.has_an_imc_question?
    AllQuestions.map{|q| q[:question_type]}.detect{|question_type| question_type == :imc_check}
  end

  def Survey.includes_nfc_assessment?
    AllQuestions.map{|q| q[:question_type]}.detect{|question_type| question_type == :need_for_cognition}
  end

  def Survey.use_kapcha?(question_type)
    Survey::UseKapcha && !Survey::QuestionTypesExemptFromKapCha.include?(question_type)
  end

  TurkSurveyorVersion = "1.0b"
end

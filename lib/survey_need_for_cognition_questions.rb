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

module SurveyNeedForCognitionQuestions
  include StatisticsTools

  #All questions in the Need for Cognition survey share these
  CommonParamsAmongNFCQuestions = {
    :question_description => %Q|Instructions: Please indicate to what extent the statement is characteristic of you.|,
    :question_type => :need_for_cognition,
    :response_type => :likert_scale,
    :other_response_params => {
      :likert_max_score => 5,
      :likert_descriptions => [
        'extremely uncharacteristic',
        'somewhat uncharacteristic',
        'uncertain',
        'somewhat characteristic',
        'extremely characteristic'
      ]
    }
  }

  #These are "need for cognition" assessment questions (see Cacioppo et al, 1984)
  #Make sure to mark the :question_type as :need_for_cognition
  NeedForCognitionQuestions = [
    {
      :signature => 'nfc_01_problems',      
      :question_text => %Q|I would prefer complex to simple problems.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_02_situation',
      :question_text => %Q|I like to have the responsibility of handling a situation that requires a lot of thinking.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_03_thinking_fun',
      :question_text => %Q|Thinking is not my idea of fun.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_04_requires_thought',
      :question_text => %Q|I would rather do something that requires little thought than something that is sure to challenge my thinking abilities.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_05_think_in_depth',
      :question_text => %Q|I try to anticipate and avoid situations where there is a likely chance I will have to think in depth about something.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_06_deliberation',
      :question_text => %Q|I find satisfaction in deliberating hard and for long hours.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_07_think_as_hard',
      :question_text => %Q|I only think as hard as I have to.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_08_short_long_term',
      :question_text => %Q|I prefer to think about small daily projects to long-term ones.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_09_require_little_thought',
      :question_text => %Q|I like tasks that require little thought once I've learned them.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_10_relying_on_thought',
      :question_text => %Q|The idea of relying on thought to make my way to the top appeals to me.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_11_new_solutions',
      :question_text => %Q|I really enjoy a task that involves coming up with new solutions to problems.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_12_new_ways',
      :question_text => %Q|Learning new ways to think doesn't excite me very much.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_13_puzzles',
      :question_text => %Q|I prefer my life to be filled with puzzles that I must solve.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_14_thinking_abstractly',
      :question_text => %Q|The notion of thinking abstractly is appealing to me.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_15_intellectual',
      :question_text => %Q|I would prefer a task that is intellectual, difficult, and important to one that is somewhat important but does not require much thought.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_16_mental_effort',
      :question_text => %Q|I feel relief rather than satisfaction after completing a task that required a lot of mental effort.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_17_utilitarian',
      :question_text => %Q|It's enough for me that something gets the job done; I don't care how or why it works.|,
    }.merge(CommonParamsAmongNFCQuestions),
    {
      :signature => 'nfc_18_deliberating_issues',
      :question_text => %Q|I usually end up deliberating about issues even when they do not affect me personally.|,
    }.merge(CommonParamsAmongNFCQuestions),
  ]
  NeedForCognitionReverseScoredQuestionIndices = [3, 4, 5, 7, 8, 9, 12, 16, 17]

  ### now we add the calculation functions...
  def calculate_average_ncs
    mean(@ncs_scores ||= need_for_cognition_scores)
  end

  def calculate_sd_ncs
    sd(@ncs_scores ||= need_for_cognition_scores)
  end

  private
  def need_for_cognition_scores
    questions = self.survey_questions.select{|q| NeedForCognitionQuestions.map{|nfcq| nfcq[:signature]}.include?(q.signature)}
    return nil if questions.length != NeedForCognitionQuestions.length
    scores = questions.map{|q| q.responses.to_i}
    #now we need to reverse score those that are reverse scored
    scores.map_with_index{|s, i| NeedForCognitionReverseScoredQuestionIndices.include?(i + 1) ? reverse_score(s) : s}
  end

  def reverse_score(score)
    case score
      when 5 then 1
      when 4 then 2
      when 3 then 3
      when 2 then 4
      when 1 then 5
    end
  end

end

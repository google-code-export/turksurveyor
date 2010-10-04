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

module SurveyDemographicQuestions
  #These are demographic questions
  #Make sure to mark the :question_type as :demographic
  DemographicQuestions = [
  {
    :signature => 'dem_01_birth_year',
    :question_type => :demographic,
    :question_text => %Q|Which year were you born?|,
    :response_type => :free_response_small,
    :other_response_params => {
      :text_before_free_response => 19,
      :input_max_characters => 2
    },
  },
    {
      :signature => 'dem_02_gender',
      :question_type => :demographic,
      :question_text => %Q|Are you male or female?|,
      :response_type => :one_of_many,
      :response_choices => ['male', 'female']
    },
    {
      :signature => 'dem_03_education',
      :question_type => :demographic,
      :question_text => %Q|What is your level of education?|,
      :response_type => :one_of_many,
      :response_choices => [
        'Some High School',
        'High School Graduate',
        'Some college, no degree',
        'Associates degree',
        'Bachelors degree',
        'Graduate degree, Masters',
        'Graduate degree, Doctorate'
      ]
    }
  ]

  #change the question signatures based on your own age / gender question implementation
  def age_gender_to_s
    birth_year_q = self.question_objects_with_respondent_data.detect{|q| q[:signature] == 'dem_01_birth_year'}
    gender_q = self.question_objects_with_respondent_data.detect{|q| q[:signature] == 'dem_02_gender'}
    age = birth_year_q.nil? ? nil : 2010 - (1900 + birth_year_q[:responses].to_i)
    "#{age.nil? ? "(no age)" : age} / #{gender_q.nil? ? "(no gender)" : gender_q[:responses]}"
  end

end
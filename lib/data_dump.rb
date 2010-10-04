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

module DataDump

  SeparationChar = '|'
  StrftimeForDates = '%m/%d/%y'
  StrftimeForTimes = '%H:%M:%S'
  def DataDump.dump(surveys, coded_responses = false)
    #first create the file
    t = Time.now
    filename = "#{RAILS_ROOT}/kapcha_dump_#{coded_responses ? "coded_" : ""}#{t.strftime('%m_%d_%y__%H_%M')}.txt"
    write_out = File.new(filename, "w")
    #if we have coded response, we need to spit out a few rows of keys
    if coded_responses
      row = []
      row << "qu_signature_for_multiple_choice_question"
      row << "possible_responses"
      write_out.puts(row.join(SeparationChar))
      Survey::AllQuestions.select{|q| Survey.question_is_a_multiple_response_question?(q[:signature]) or Survey.question_is_a_multiple_choice_question?(q[:signature])}.each do |q|
        row = []
        row << q[:signature]
        row << q[:response_choices]
        write_out.puts(row.flatten.join(SeparationChar))
      end
    end

    #header
    row = []
    row << "id"
    row << "version"
    row << "treatment_run"
    row << "created_at_date"
    row << "created_at_time"
    row << "expired_at_date"
    row << "expired_at_time"
    row << "read_directions_at_date"
    row << "read_directions_at_time"
    row << "mturk_worker_id"
    row << "expired?"
    row << "started_at_date"
    row << "started_at_time"
    row << "treatment_q1_place"
    row << "treatment_q2_ticket_price"
    row << "ip_address"
    row << "qu_signature"
    row << "qu_responses"
    row << "qu_responses_num_words"
    row << "qu_time_date"
    row << "qu_time_time"
    row << "finished_at_date"
    row << "finished_at_time"
    row << "paid_at_date"
    row << "paid_at_time"
    row << "bonus_level"
    row << "num_windows_switches"
    row << "notes"
    write_out.puts(row.join(SeparationChar))
    
    #now each survey question gets Q rows where Q is the number of questions
    #the worker completed
    surveys.each do |s|
      if s.expired? and s.survey_questions.empty?
        row = []
        row << s.id
        row << s.version
        row << s.treatment[:run]
        row << s.created_at.strftime(StrftimeForDates)
        row << s.created_at.strftime(StrftimeForTimes)
        row << s.to_be_expired_at.strftime(StrftimeForDates)
        row << s.to_be_expired_at.strftime(StrftimeForTimes)
        row << (s.read_directions_at.nil? ? '' : s.read_directions_at.strftime(StrftimeForDates))
        row << (s.read_directions_at.nil? ? '' : s.read_directions_at.strftime(StrftimeForTimes))
        row << s.mturk_worker_id
        row << 1
        write_out.puts(row.join(SeparationChar))
      else
        s.survey_questions.each do |q|
  #        next if q[:signature] == 'feedback_question' or q[:signature] == 'kapcha_speed_question'
          row = []
          row << s.id
          row << s.version
          row << s.treatment[:run]
          row << s.created_at.strftime(StrftimeForDates)
          row << s.created_at.strftime(StrftimeForTimes)
          row << s.to_be_expired_at.strftime(StrftimeForDates)
          row << s.to_be_expired_at.strftime(StrftimeForTimes)
          row << s.read_directions_at.strftime(StrftimeForDates)
          row << s.read_directions_at.strftime(StrftimeForTimes)
          row << s.mturk_worker_id
          row << (s.expired_and_uncompleted? ? 1 : 0)
          row << (s.started_at.nil? ? 'no information' : s.started_at.strftime(StrftimeForDates))
          row << (s.started_at.nil? ? 'no information' : s.started_at.strftime(StrftimeForTimes))
          row << s.treatment[:place]
          row << s.treatment[:ticket_price]
          row << s.ip_address
          row << q[:signature]
          if coded_responses and Survey.question_is_a_multiple_response_question?(q[:signature])
            row << Survey.dump_multiple_responses_coded(q[:responses], q)
          elsif coded_responses and Survey.question_is_a_multiple_choice_question?(q[:signature])
            row << Survey.dump_single_response_coded(q[:responses], q)
          elsif coded_responses and Survey.question_is_a_free_response_large_question?(q[:signature])
            row << 'free_response' #comment these out if you don't want it
          else
            row << DataDump.safe_string(q[:responses])
          end
          row << q[:responses].to_s.split(/\s/).length
          row << q.created_at.strftime(StrftimeForDates)
          row << q.created_at.strftime(StrftimeForTimes)
          row << (s.finished_at.nil? ? 'no information' : s.finished_at.strftime(StrftimeForDates))
          row << (s.finished_at.nil? ? 'no information' : s.finished_at.strftime(StrftimeForTimes))
          row << (s.paid_at.nil? ? 'no information' : s.paid_at.strftime(StrftimeForDates))
          row << (s.paid_at.nil? ? 'no information' : s.paid_at.strftime(StrftimeForTimes))
          row << s.treatment[:bonus]
          row << s.browser_statuses.length
          row << DataDump.safe_string(s.notes)
          write_out.puts(row.join(SeparationChar))
        end        
      end
    end

    write_out.close
    filename
  end

  private
  LinebreakToken = "<<<linebreak>>>"
  DelimeterToken = "<<<delimeter>>>"
  def DataDump.safe_string(str)
    str = str.to_s.gsub("\r\n", LinebreakToken)
    str = str.to_s.gsub("\n", LinebreakToken)
    str = str.to_s.gsub("\r", LinebreakToken)
    str = str.to_s.gsub(SeparationChar, DelimeterToken)
  end
end
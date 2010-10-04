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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include StatisticsTools
  
  def rounded_div(options = {}, &block)
    rounded_corner = RoundedCorner.generate_rounded_corner(options[:radius], options[:border_color], options[:interior_color])
    concat(rounded_corner.generate_top_html(options[:padding]), block.binding)
    concat(capture(&block), block.binding)
    concat(rounded_corner.generate_bottom_html, block.binding)
  end

	def convert_seconds_to_time(seconds)
    return nil if seconds.nil?
	  minutes = seconds.to_i / 60
	  seconds = (seconds - minutes * 60).to_i
    "#{minutes}m #{seconds}s"
	end

  def median_mean_sd_rounded(arr)
    begin
      x_bar = mean(arr)
      med = median(arr)
      s = sd(arr)
      "<i>#{med.nil? ? nil : digits_round(med)}</i> #{x_bar.nil? ? 'nil' : digits_round(x_bar, 2)} &plusmn; #{s.nil? ? 'nil' : digits_round(s)}"
    rescue
      "crash"
    end
  end

  def pct(sum, n, digits = 1)
    return 'nil' if sum.nil? or n.nil? or n.zero?
    "#{digits_round(sum / n.to_f * 100, digits)}%"
    
  end

  def digits_round(num, digits = 1)
    return 'nil' if num.nil?
    "#{"%.#{digits}f" % num}"
  end

  def combine_two_collections(arr1, arr2)
    raise "array 1 nil" if arr1.nil?
    raise "array 2 nil" if arr2.nil?
    raise "array 1 empty" if arr1.empty?
    raise "array 2 empty" if arr2.empty?
    raise "array 1 and array 2 are not of equal length" if arr1.length != arr2.length
    combined = []
    arr1.each_with_index{|e, i| combined << [e, arr2[i]]}
    combined
  end
end

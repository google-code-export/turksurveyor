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

require 'rubystats/normal_distribution'

module StatisticsTools

  StdNormalDist = Rubystats::NormalDistribution.new(0, 1)

  AlphaLevel = 0.05

  def randomly_sample_one(choices, probabilities = nil)
    #handle easy case first
    return choices[(rand * choices.length).floor] if probabilities.nil?

    raise "probabilities array not specified correctly" if probabilities.length != choices.length || probabilities.inject(0){|sum, p| sum + p} != 1
    total_prob = 0
    rand_no = rand
    choices.each_with_index do |c, i|
      total_prob += probabilities[i]
      return c if rand_no < total_prob
    end
    choices.last
  end

  def median(arr)
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.empty?
    return arr.first if arr.length == 1
    arr = arr.sort{|a, b| a <=> b}
    l = arr.length
    l % 2 == 0 ? ((arr[l / 2 - 1] + arr[l / 2]) / 2.to_f) : arr[(l / 2.to_f).floor]
  end

  def mean(arr)
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.empty?
    arr.inject(0){|sum, i| sum + i} / arr.length.to_f
  end

  #sample variance (s^2)
  def variance(arr)
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.length <= 1
    x_bar = mean(arr)
    arr.inject(0){|sum, i| sum + ((i - x_bar) ** 2)} / (arr.length - 1).to_f
  end

  def sd(arr)
    return nil if arr.nil?
    arr = arr.reject{|e| e.nil?}
    return nil if arr.length <= 1
    Math.sqrt(variance(arr))
  end

  #Welch's t-test assume H_0: \mu_1 - \mu_2 = 0 i.e. no difference in means
  #if std errors ratios are within a certain epsilon, used pooled approach
  VarRatioSameCutoff = 3 #yay Stat 102
  def two_sample_t_test(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    pooled_or_unpooled, st_err_diff = if ssq_1 / ssq_2 < VarRatioSameCutoff || ssq_2 / ssq_1 < VarRatioSameCutoff
                    #use pooled
                    ['p', Math.sqrt(((n_1 - 1) * ssq_1 + (n_2 - 1) * ssq_2) / (n_1 + n_2 - 2)) * Math.sqrt(1 / n_1 + 1 / n_2)]
                  else
                    #use unpooled
                    ['u', Math.sqrt(ssq_1 / n_1 + ssq_2 / n_2)]
                  end
    [x_bar_diff / st_err_diff, pooled_or_unpooled]
  end

  def two_sampe_t_test_unpooled(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    x_bar_diff / Math.sqrt(ssq_1 / n_1 + ssq_2 / n_2)
  end

  def two_sample_t_test_pooled(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    x_bar_diff / (Math.sqrt(((n_1 - 1) * ssq_1 + (n_2 - 1) * ssq_2) / (n_1 + n_2 - 2)) * Math.sqrt(1 / n_1 + 1 / n_2))
  end

  def two_proportion_z_test_unpooled(r_1, n_1, r_2, n_2)
    return nil if r_1.nil? or n_1.nil? or r_2.nil? or n_2.nil?
    return nil if n_1.zero? or n_2.zero?
    diff, st_err_diff = diff_props_stderr(r_1, n_1, r_2, n_2)
    diff / st_err_diff
  end

  def two_tailed_normal_probability(z)
    return nil if z.nil?
    2 * (1 - StdNormalDist.cdf(z.abs))
  end

  def power_of_unpooled_t_test(samp_1, samp_2)
    return nil if samp_1.nil? or samp_2.nil?
    samp_1 = samp_1.reject{|e| e.nil?}
    samp_2 = samp_2.reject{|e| e.nil?}
    return nil if samp_1.length <= 1 or samp_2.length <= 1
    x_bar_diff, ssq_1, ssq_2, n_1, n_2 = diff_variances_ns(samp_1, samp_2)
    s = Math.sqrt(ssq_1 / n_1 + ssq_2 / n_2) #i.e. the unpooled estimate of std error
    x_bar_star = 0 + StdNormalDist.icdf(1 - AlphaLevel / 2) * s #diff* + z* x s
    alt_hypothesis = Rubystats::NormalDistribution.new(x_bar_diff.abs, s)
    begin
      1 - alt_hypothesis.cdf(x_bar_star || 0)
    rescue
      0
    end
  end

  def power_of_two_prop_z_test(r_1, n_1, r_2, n_2)
    return nil if r_1.nil? or n_1.nil? or r_2.nil? or n_2.nil?
    return nil if n_1.zero? or n_2.zero?
    diff, st_err_diff = diff_props_stderr(r_1, n_1, r_2, n_2)
    diff_star = 0 + StdNormalDist.icdf(1 - AlphaLevel / 2) * st_err_diff #diff* + z* x s
    alt_hypothesis = Rubystats::NormalDistribution.new(diff.abs, st_err_diff)
    begin
      1 - alt_hypothesis.cdf(diff_star || 0)
    rescue
      0
    end
  end

  def diff_variances_ns(samp_1, samp_2)
    [mean(samp_1) - mean(samp_2), variance(samp_1), variance(samp_2), samp_1.length.to_f, samp_2.length.to_f]
  end

  def diff_props_stderr(r_1, n_1, r_2, n_2)
    prop_1 = r_1 / n_1.to_f
    prop_2 = r_2 / n_2.to_f
    [prop_1 - prop_2, Math.sqrt(prop_1 * (1 - prop_1) / n_1.to_f + prop_2 * (1 - prop_2) / n_2.to_f), prop_1, prop_2]
  end
end
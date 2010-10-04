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


# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AdminAuthentication

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '6c33ecb52509c01fe26af110972d9507'


  session :session_key => "_#{PersonalInformation::ProjectName}_session_id"

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password

 before_filter :big_brother_track #track what users are doing

  ControllersNotToTrack = %w()
  def big_brother_track
    #don't log certain controller's activity
    return if ControllersNotToTrack.include?(controller_name)
    #now log it:
    bbt = BigBrotherTrack.create({
      :controller => controller_name,
      :action => params[:action],
      :mturk_worker_id => params[:workerId], #if the user is working on our hits
      :ip => request.remote_ip,
      :method => request.method.to_s,
      :ajax => request.xhr?
    })

    # Log the parameters.
    params.each do |key, val|

      #we've already got these:
      next if %w(action controller entry language).include?(key)

      # Don't retain files
      next unless val.is_a?(String)
      BigBrotherParam.create({
        :param => key.to_s,
        :value => val.to_s,
        :big_brother_track => bbt
      })
    end
    return true
  end
end
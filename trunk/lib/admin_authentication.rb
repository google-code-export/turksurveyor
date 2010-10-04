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

module AdminAuthentication

  def admin_required
    return true if logged_in?
    flash[:error] = 'Unauthorized entry'
    redirect_to '/'
    return false
  end
  
  def admin_login(pw)
    if pw == PersonalInformation::AdminPassword
      session[:admin] = true
    end
  end
  
  def logged_in?
    session[:admin]
  end
  
  def admin_logout
    session[:admin] = nil
  end  
  
  #add these functions as a helper method to any including library
  #(since the including library is the parent controller, it gets added
  #as a helper function who's scope is any controller!)
  def self.included(base)
    begin
      base.send(:helper_method, :logged_in?)
    rescue #I don't care if the class doesn't have helper methods
    end
  end
end

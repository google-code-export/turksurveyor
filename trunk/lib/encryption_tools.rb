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

require 'crypt/blowfish' 

module EncryptionTools
  #don't touch this under any circumstances!!!
  BlowfishEncrypter = Crypt::Blowfish.new(PersonalInformation::AdminPassword + '&Fesgm$Sg9GSwQBE!@RGHSesge')
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def b_encrypt(string)
      BlowfishEncrypter.encrypt_string(string.to_s).unpack('H*')[0]
    end

    def b_decrypt(string)
      BlowfishEncrypter.decrypt_string([string].pack('H*'))
    end
    
    ######
    ##
    ## For ActiveRecord models
    ##     
  
    def find_by_encrypted_id(encrypted_id, *options)
      find(b_decrypt(encrypted_id), *options)
    end
  end

  #these methods should be accessible from the class itself for convenience?
  def b_encrypt(string)
    self.class.b_encrypt(string)
  end
  
  def b_decrypt(string)
    self.class.b_decrypt(string)
  end  
  
  ######
  ##
  ## For ActiveRecord models
  ## 
  
  def encrypted_id
    b_encrypt(self.id)
  end  
  
end
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

class RoundedCorner < ActiveRecord::Base

  validates_presence_of :identifier_label

  StylesheetForRoundedStatements = 'rounded.css'

  DefaultRoundedRadius = 20
  DefaultColor = 'rgb(255, 255, 255)' #white
  
  AlertRadius = 15
  ErrorColor = 'rgb(255, 0, 0)'
  WarningColor = 'rgb(255, 153, 0)'
  ProceedColor = 'rgb(51, 204, 0)'
  NeutralColor = 'rgb(51, 51, 51)'
  White = 'rgb(255,255,255)'
  Black = 'rgb(0, 0, 0)'
  Red = 'rgb(255, 0, 0)'
  Grey = 'rgb(100, 100, 100)'

  def RoundedCorner.generate_rounded_corner(radius, border, interior)
    #ensure defaults if params are nil
    radius = radius || DefaultRoundedRadius
    border = border || DefaultColor
    interior = interior || DefaultColor
    #do not generate css if it has been "built" already
    rounded_corner = RoundedCorner.find_by_radius_and_border_and_interior(radius, border, interior)
    unless rounded_corner
      #make sure we record that this configuration has been completed
      rounded_corner = RoundedCorner.create(:radius => radius, :border => border, :interior => interior)
      #now generate the css and amend the stylesheet
      rounded_corner.generate_css_and_amend_stylesheet
    end
    rounded_corner
  end
  
  RegexToModifyColorCodes = /\s|\W/
  def identifier_label
    "#{self.border.gsub(RegexToModifyColorCodes, '_')}__#{self.interior.gsub(RegexToModifyColorCodes, '_')}__#{self.radius}____"
  end
  
  DefaultContentDivPadding = '0px 10px 0px 10px'
#  MoveMarginUpFactor = 0.1
  def generate_top_html(padding = nil)
    #get default padding
    padding ||= DefaultContentDivPadding
#    margin = "-#{(self.radius * MoveMarginUpFactor).round}px 0px -#{(self.radius * MoveMarginUpFactor).round}px 0px;"
    #now generate the html
    top = []
    top.push "<div>"
    top.push "  <span class='roundcorner_#{self.radius}_#{self.identifier_label}'>"
    0.upto(self.radius) do |i|
      top.push "  <span class='roundcorner_#{self.radius}_#{self.identifier_label}#{i}'></span>"
    end
    top.push "  </span>"
    top.push "  <div class='roundcorner_#{self.radius}_#{self.identifier_label}_content' style='padding:#{padding};'>" # margin:#{margin}
    top.join('')
  end
  
  def generate_bottom_html
    bottom = []
    bottom.push "  </div>"
    bottom.push "  <span class='roundcorner_#{self.radius}_#{self.identifier_label}'>"
    (self.radius).downto(0) do |i|
      bottom.push "<span class='roundcorner_#{self.radius}_#{self.identifier_label}#{i}'></span>"
    end
    bottom.push "  </span>"
    bottom.push "</div> "
    bottom.join('')
  end
  
  def generate_array_of_margins
    return @array if @array
    @array = []
    # create an array of margin values
    0.upto(self.radius - 1) do |i|
       x = i.to_f / self.radius
       y = 1.0 - Math.sqrt(1.0-(x * x))
       r = (y * self.radius).to_i
       @array << r if r > 0
    end
    @array   
  end
  
  def generate_css_and_amend_stylesheet

=begin
This function was sourced from another author. Below is his license. By
using this code, you agree to his license

/***************************************************************************
 *   Copyright (C) 2008, Paul Lutus                                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

see http://www.arachnoid.com/ruby/round_css_corners/

=end
    
    #convert to html color codes if not rgb and convert the radius to an integer (shouldn't be necessary though)
    border = self.border =~ /rgb/ ? self.border : "##{self.border}"
    interior = self.interior =~ /rgb/ ? self.interior : "##{self.interior}"
    radius = self.radius.to_i
    
    #otherwise, go ahead and generate it:
    graphic_background = (interior =~ /url\(/i)
    #autogenerate unique id for this configuration as the timestamp
    css_baseclass = "roundcorner_#{radius}_#{self.identifier_label}"
    


    # content of CSS file
    roundcorner_css = ".#{css_baseclass} {\ndisplay: block;\n}\n\n"
    roundcorner_css += ".#{css_baseclass} * {\ndisplay:block;\noverflow:hidden;\nheight:1px;"

    roundcorner_css += graphic_background ? "\nbackground: #{interior};" : "\nbackground-color: #{interior};\nborder-left:1px solid #{border};\nborder-right:1px solid #{border};"
    roundcorner_css += "\n}\n\n"

    generate_array_of_margins.reverse.each_with_index do |item, n|
       roundcorner_css += ".#{css_baseclass}#{n} {\nmargin-right: #{item}px;\nmargin-left: #{item}px;"
       if(graphic_background)
          roundcorner_css += "\nbackground-position: -#{item}px -#{n}px;"
       else
          if(n == 0)
             roundcorner_css += "\nbackground-color: #{border};"
          end
       end
       if(n > 0)
          # stretch the border width for certain radii
          bw = 1+(item/6)
          roundcorner_css += "\nborder-left:#{bw}px solid #{border};"
          roundcorner_css += "\nborder-right:#{bw}px solid #{border};"
       end
       roundcorner_css += "\n}\n\n"
    end

    roundcorner_css += ".#{css_baseclass}_content {\npadding-right:#{radius}px;\npadding-left:#{radius}px;\ndisplay:block;"
    roundcorner_css += graphic_background ? "\nbackground: #{interior};\nbackground-position: 0px -#{generate_array_of_margins.length}px;" : "\nbackground-color: #{interior};"
    roundcorner_css += "\nborder-left:1px solid #{border};"
    roundcorner_css += "\nborder-right:1px solid #{border};"
    roundcorner_css += "\n}\n\n"

    # prettify the CSS

    prettified_css = "\n\n"
    tab = 0

    roundcorner_css.each do |line|
       tab -= 1 if(line =~ /\}/)
       prettified_css += "  " * tab + line
       tab += 1 if(line =~ /\{/)
    end

    # save the CSS to the rails css file:
    File.open("#{RAILS_ROOT}/public/stylesheets/#{StylesheetForRoundedStatements}", "a+"){|f| f.write(prettified_css)}    
  end    
end

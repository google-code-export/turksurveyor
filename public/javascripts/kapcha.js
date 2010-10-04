/*
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
*/

var time_for_controls_to_fade_in_upon_completion = 2;

//this is for if you just want to do the timing control, not the fade in
var TimerBaseClass = Class.create();
Object.extend(TimerBaseClass.prototype, {
  //ivars
  words_per_minute : null,
  seconds_per_word : null,
  time_for_token_to_fade_in : null,
  tokens : null,

  initialize : function(words_per_minute){
    this.words_per_minute = words_per_minute;
    //calculate... q words / minute * 1 min / 60 seconds = q/60 words / second <=> 60/q seconds / word
    this.seconds_per_word = 60 / words_per_minute;
    this.time_for_token_to_fade_in = this.seconds_per_word * 2 / 3;
    //get all the tokens from the document to render
    this.tokens = $$('.kapcha_token');
  }
});

// runs the dynamic fade-ins of the words
var KapCha = Class.create();
Object.extend(KapCha.prototype, TimerBaseClass.prototype);
Object.extend(KapCha.prototype, {

  //static finals
//  active_token_color : 'rgb(116, 229, 43)',

  //ivars
  rewind_upon_navigate_away : null,
  fading_in : false,
  done_fading_in : false,
  rewound : false,
//  original_text_color : null,
  
  initialize : function(words_per_minute, rewind_upon_navigate_away){
    this.rewind_upon_navigate_away = rewind_upon_navigate_away;
//    this.original_text_color = $('survey_body').style.color;
    TimerBaseClass.prototype.initialize.call(this, words_per_minute);
    //render token by token (if there are tokens of course)
    //when it's done, the controls will fade-in
    if (!rewind_upon_navigate_away || browser_focused){
      this.start_fading_in();
    }
  },

  start_fading_in : function(){
    //if we are already fading it in, don't do it again
    if (this.fading_in){
        return;
    }
    this.rewound = false;
    //begin fading in by rendering the first token,
    //the first token will then call the second token,
    //and dominoes...
    if (this.tokens.length > 0){
        setTimeout(function(){
            this.render_token(0);
        }.bind(this), this.seconds_per_word * 1000);
    }
  },

  //uncomment the setStyle lines for leading word to be colored the active_token_color
  render_token : function(i){
    if (this.rewound){
        return; //get out
    }
    this.fading_in = true;
    //now color it correctly and fade it in
    //this.tokens[i].setStyle({color : this.active_token_color});
    this.tokens[i].appear({duration: this.time_for_token_to_fade_in});
    //now wait until the next render if we're not done
    if (i < this.tokens.length - 1){
        setTimeout(function(){
          if (this.rewound){
            return; //get out
          }
          //uncolor previous
          //this.tokens[i].setStyle({color : this.original_text_color});
          //render next token
          this.render_token(i + 1);
        }.bind(this), this.seconds_per_word * 1000);
    }
    //we're done, show the controls
    else {
        //this.tokens[i].setStyle({color : this.original_text_color});
        this.fade_in_all_controls();
        this.done_fading_in = true;
        this.fading_in = false;
    }
  },

  rewind : function(){
      //no rewinding allowed if we are already done
      if (this.done_fading_in){
          return;
      }
      this.rewound = true;
      this.fading_in = false;
      this.tokens.each(function(token){
        token.hide();
      });
      setTimeout(function(){
        this.tokens.each(function(token){
          token.hide();
        });
      }.bind(this), this.time_for_token_to_fade_in * 1000);
  },

  fade_in_all_controls : function(){
    $$('.kapcha_control').each(function(control){
      control.appear({duration: time_for_controls_to_fade_in_upon_completion});
    });
  }
});

var Timing = Class.create();
Object.extend(Timing.prototype, TimerBaseClass.prototype);
Object.extend(Timing.prototype, {

  initialize : function(words_per_minute){
    TimerBaseClass.prototype.initialize.call(this, words_per_minute);
    //wait an appropriate amount of time then show the continue button
    var time_to_wait = this.seconds_per_word * this.tokens.length; //in s
//    alert($('question_signature').value + "," + time_to_wait);
    setTimeout(function(){
        //kill the spinner
        $('kapcha_submit_spinner').hide();
        $('kapcha_can_continue').show();
        //re-enable the button
        $('kapcha_submit_button').disabled = false;
        //now for the actual button, do a number of things:
        $('kapcha_submit_button').observe('click', function(){SubmitSurvey();});
        $('kapcha_submit_button').setStyle({color : "black"});
        $('kapcha_submit_button').setStyle({cursor : "pointer"});
    }.bind(this), time_to_wait * 1000);
  }
});
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

class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      #autopopulated
      t.string :mturk_hit_id
      t.string :mturk_group_id
      t.integer :version, :limit => 3      
      t.float :wage
      t.string :country, :limit => 2
      t.datetime :created_at
      t.datetime :to_be_expired_at
      #experimental variables
      t.text :treatment
      #populated when hit is accepted
      t.string :ip_address
      t.string :mturk_assignment_id
      t.string :mturk_worker_id      
      t.datetime :started_at
      #and after they finish the directions
      t.datetime :read_directions_at
      #and when they finish it
      t.datetime :finished_at
      #for our own notes
      t.text :notes
      #populated when hit is checked over by admin
      t.datetime :rejected_at
      t.datetime :paid_at
      t.float :bonus
    end
    add_index :surveys, :mturk_worker_id
  end

  def self.down
    drop_table :surveys
  end
end

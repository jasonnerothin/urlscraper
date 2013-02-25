class WordCount < ActiveRecord::Base

  include Comparable

  attr_accessible :count, :word, :page_id

  belongs_to :page

  # make our word counts comparable
  def self.<=>(other)
    result = 0
    if other[:count] < self[:count]
      result = -1
    elsif other[:count] > self[:count]
      result = 1
    end
    if result != 0
      result
    else
      self[:word] <=> other[:word]
    end
  end

  def self.inspect
    'word: #@word, count: #@count, page_id: #@page_id'
  end

end

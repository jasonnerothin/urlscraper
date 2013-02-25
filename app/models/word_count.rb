class WordCount < ActiveRecord::Base

  include Comparable

  attr_accessible :count, :word, :page_id

  belongs_to :page

  #def initialize(word, count, page_id)
  #  raise("Word and count are required attributes of a WordCount object.") if word.nil? || count.nil?
  #  raise("Count must be greater than zero.") unless count > 0
  #  raise("page_id is required.") unless count > 0
  #  @word = word
  #  @count = count
  #  @page_id = page_id
  #end

  # make our word counts comparable
  def <=>(other)
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

  def inspect
    "Word: #@word, Count: #@count"
  end

  def count
    @count
  end

  def word
    @word
  end

  def page_id
    @page_id
  end

end

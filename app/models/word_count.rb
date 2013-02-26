class WordCount < ActiveRecord::Base

  include Comparable

  attr_accessible :count, :word, :page_id

  belongs_to :page

  # todo delete when you prove that it's not used anyway...
  # make our word counts comparable
  def self.<=>(other)
    result = nil_compare(other, :count)
    unless result != 0
      if other[:count] < self[:count]
        result = 1
      elsif other[:count] > self[:count]
        result = -1
      else
        result = 0
      end
      unless result != 0
        result = nil_compare(other, :word)
        unless result != 0
          result = self[:word] <=> other[:word]
        end
      end
    end
    result
  end

  def self.inspect
    'word: #@word, count: #@count, page_id: #@page_id'
  end

  # todo this should be in its own Module or class
  def nil_compare(other, attrName)
    result = 0
    if self[attrName].nil?
      unless other.any(attrName).nil?
        result = 1
      end
    else
      if other.nil? || other[attrName].nil?
        result -1
      else
        result = self[attrName] <=> other[attrName]
      end
    end
    result
  end

end
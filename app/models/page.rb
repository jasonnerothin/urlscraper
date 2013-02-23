require "json"

class Page < ActiveRecord::Base

  def initialize(url)
    raise("Cannot initialize a page instance without a URL.") if url.nil?
    @words = Set.new
    @url = url
  end

  def words
    @words
  end

  def to_json(*a)
    {
        "url" => @url,
        "words" =>
            @words.sort.each do |word|
              word.to_json
            end
    }.to_json(*a)
  end

  def self.json_create(o)
    new(o["data"]["url"], o["data"]["words"])
  end

  def push(word)
    @words.add(word) unless @words.length == 10
    @words.sort
  end

  def most_common_word
    if @words.size == 0
      ""
    else
      @words.sort.to_a[0]
    end
  end

end

# a little immutable helper class
class WordCount

  include Comparable

  def initialize(word, count)
    raise("Word and count are required attributes of a WordCount object.") if word.nil? || count.nil?
    raise("Count must be greater than zero.") unless count > 0
    @word = word
    @count = count
  end

  def to_json(*a)
    {
        "word" => @word,
        "count" => @count
    }.to_json(*a)
  end

  def self.json_create(o)
    new(o["data"]["word"], o["data"]["count"])
  end

  def <=>(other)
    result = other.count <=> self.count
    if result != 0
      result
    else
      self.word <=> other.word
    end
  end

  def word
    @word
  end

  def count
    @count
  end

  def inspect
    "Word: #{@word}, Count: #{@count}"
  end

end
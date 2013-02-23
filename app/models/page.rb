require "json"

# A model class that keeps track of word counts for a text resource mapped by a URL.
# A webpage is a quite obvious example.
class Page < ActiveRecord::Base

  def words
    if @words.nil?
      Set.new()
    else
      @words
    end
  end

  def url
    @url
  end

  def json
    to_json
  end

  def to_json(*a)
    if @words.nil?
      @words = Set.new()
    end
    {
        :id => id,
        :url => @url,
        :words =>
            @words.sort.each do |word|
              word.to_json
            end
    }.to_json(*a)
  end

  # deserialize as json
  def self.json_create(o)
    new(o[:data][:url], o[:data][:words], o[:data][:id])
  end

  # Attempt to push a new WordCount into the set.
  # This attempt is only successful if the WordCount is
  # higher than the least common word currently in the set.
  # Note that this method is potentially "lossy" (because
  # words with identical frequency can be dropped off the
  # list.) This is a reasonable trade-off for the smaller
  # memory footprint. We expect most pages to have a
  # normal distribution, so the likelihood is that the
  # less common words will crowd each other out. And
  # the uncommon words are implicitly the ones we're
  # disinterested in.
  def push(word)
    if @words.nil?
      @words = Set.new()
    end
    if @words.length < 10
      @words.add(word)
    else # 10 words already
      unless least_common.nil?
        if word.count > least_common.count
          delete_least_common
          @words.add(word)
        end
      end
    end
    @words.sort
  end

  # the most common word we are keeping track of
  def most_common_word
    if @words.size == 0
      ""
    else
      @words.sort.to_a[0]
    end
  end

  # returns the least common word count
  # or nil if there are no recorded words
  # yet
  def least_common
    sz = @words.size
    if sz > 0
      @words.sort.to_a[sz-1]
    else
      nil
    end
  end

  # deletes the least common word in the set
  def delete_least_common
    lc = least_common
    @words.delete(lc) unless lc.nil?
  end

end

# a little immutable helper class
class WordCount

  include Comparable

  # ctor
  def initialize(word, count)
    raise("Word and count are required attributes of a WordCount object.") if word.nil? || count.nil?
    raise("Count must be greater than zero.") unless count > 0
    @word = word
    @count = count
  end

  # serialization to json
  def to_json(*a)
    {
        "word" => @word,
        "count" => @count
    }.to_json(*a)
  end

  # from json
  def self.json_create(o)
    new(o["data"]["word"], o["data"]["count"])
  end

  # make our word counts comparable
  def <=>(other)
    result = other.count <=> self.count
    if result != 0
      result
    else
      self.word <=> other.word
    end
  end

  # convenience accessor
  def word
    @word
  end

  # so we can look and touch
  def count
    @count
  end

  # for IDE giggles
  def inspect
    "Word: #{@word}, Count: #{@count}"
  end

end
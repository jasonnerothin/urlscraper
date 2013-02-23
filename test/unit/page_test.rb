require 'test_helper'
require 'random_data'

class PageTest < ActiveSupport::TestCase

  def setup
    @rand = RandomDataHelper.new()
    @w0 = WordCount.new("wobble", 18)
    @w1 = WordCount.new("wibble", 29)
    @w2 = WordCount.new("wubble", 3999)
    @w3 = WordCount.new("flob", 100000)

    @instance = Page.new("http://jasonnerothin.com")
  end

  def test_to_json
    puts @instance.to_json
  end

  def test_push
    @instance.push @w0
    @instance.push @w3
    @instance.push @w2
    @instance.push @w1

    # ensure that we can't re-add the same word
    size = @instance.words.size
    @instance.push @w0
    assert_equal size, @instance.words.size

    # ensure that we max out at 10 no matter how hard we try
    (0..15).each do @instance.push random_word_count end
    assert_equal( 10, @instance.words.size )


    puts @instance.to_json

  end

  def random_word_count
    WordCount.new(@rand.random_string, rand(23) + 1)
  end

  # sorts by count (ascending) and then by word (asciibetically)
  def test_word_count_sort

    a = WordCount.new("a", 1)
    b = WordCount.new("b", 1)
    c = WordCount.new("c", 23)

    arr = [a,b, c].sort

    assert_same(arr[0],c)
    assert_same(arr[1],a)
    assert_same(arr[2],b)

  end

  def test_most_common_word

    me = WordCount.new("jason",38)

    @instance.push WordCount.new("shelley", 37)
    @instance.push me
    @instance.push WordCount.new("elida",7)
    @instance.push WordCount.new("ruby",5)
    @instance.push WordCount.new("peter",2)

    assert_same(@instance.most_common_word, me, "I should be the most common since I'm 38.")


  end


end

require 'test_helper'
require 'random_data'

class PageTest < ActiveSupport::TestCase

  def setup
    @rand = RandomDataHelper.new()
    @w0 = WordCount.new("wobble", 18)
    @w1 = WordCount.new("wibble", 29)
    @w2 = WordCount.new("wubble", 3999)
    @w3 = WordCount.new("flob", 100000)

    @instance = Page.new()
    @instance[:url] = "http://jasonnerothin.com"
    @instance.save()
  end

  def teardown
    @instance.delete()
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

    me = push_my_family 0

    assert_same @instance.most_common_word, me, "I should be the most common since I'm 38."

  end

  def push_my_family( idx )

    jpn = WordCount.new("jason",38)
    smn = WordCount.new("shelley", 37)
    emn = WordCount.new("elida",7)
    rpn = WordCount.new("ruby",5)
    pdn = WordCount.new("peter",2)

    @instance.push smn
    @instance.push jpn
    @instance.push emn
    @instance.push rpn
    @instance.push pdn

    [jpn,smn,emn,rpn,pdn][idx]

  end

  def test_least_common

    pete = push_my_family 4

    assert_same(@instance.least_common, pete, "Pete's the least.")

  end

  def test_delete_least_common

    ruby = push_my_family 3

    @instance.delete_least_common

    assert_same(@instance.least_common, ruby)

  end

  def test_find_by_id

    actual = Page.find 1

    assert_not_nil actual
    assert_equal 'http://jasonnerothin.com/app/index.html', actual[:url]
    assert_equal 1, actual[:id]
    assert_equal Set.new(), actual.words()

  end


end

require 'test_helper'
require 'random_data'

class PageTest < ActiveSupport::TestCase

  def setup
    @rand = RandomDataHelper.new()

    @instance = Page.new
    @instance[:url] = "http://jasonnerothin.com/app/index.html"
    #@instance[:word_counts] = Set.new
    assert_equal true, @instance.save

    @w0 = WordCount.new(:word=>"wobble", :count=>18, :page_id=>@instance.id)
    assert_equal true, @w0.save

    @w1 = WordCount.new(:word=>"wibble", :count=>29, :page_id=>@instance.id)
    assert_equal true, @w1.save

    @w2 = WordCount.new(:word=>"wubble", :count=>3999, :page_id=>@instance.id)
    assert_equal true, @w2.save

    @w3 = WordCount.new(:word=>"flob", :count=>100000, :page_id=>@instance.id)
    assert_equal true, @w3.save

  end

  def teardown
    #@instance.destroy
    #@w0.destroy
    #@w1.destroy
    #@w2.destroy
    #@w3.destroy
  end

  test "to_json doesn't just blow up" do
    some_json = @instance.to_json
  end

  #test "valid? and invalid? work correctly" do
  #  page = Page.new
  #
  #  page.url = nil
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  required = 'URL required'
  #  has_error page, required
  #
  #  page.url = ''
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  has_error page, required
  #
  #  page.url = ' '
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  has_error page, required
  #
  #  page.url = "http://jasonnerothin.com/"
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  invalid = 'Invalid URL'
  #  has_error page, invalid
  #
  #  page.url = "gopher://foo.bar.gov/"
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  has_error page, "http: is the only protocol"
  #
  #  page.url = 'http://news.google.com'
  #  lacks_error page, invalid
  #
  #  json_msg = 'serialized to json'
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  has_error page, json_msg
  #
  #  wc = WordCount.new 'blarney', 234
  #  page.push wc
  #  assert_equal false, page.valid?
  #  assert_equal true, page.invalid?
  #  has_error page, json_msg
  #
  #  page.init_json
  #  assert_equal true, page.valid?
  #  assert_equal false, page.invalid?
  #  lacks_error page, json_msg
  #
  #end

  def has_error( page, msg )
    found = false
    page.errors.full_messages.each do |fm|
      unless fm.nil?
        if fm.to_s =~ /msg.to_s/
          found = true
        end
      end
    end
    found
  end

  def lacks_error( page, msg )
    !has_error page, msg
  end

  def test_push
    @instance.push @w0
    @instance.push @w3
    @instance.push @w2
    @instance.push @w1

    # ensure that we can't re-add the same word
    size = @instance.word_counts.size
    @instance.push @w0
    assert_equal size, @instance.word_counts.size

    # ensure that we max out at 10 no matter how hard we try
    (0..15).each do @instance.push random_word_count end
    assert_equal( 10, @instance.word_counts.size )

    puts @instance.to_json

  end

  def random_word_count
    WordCount.new(:word=>@rand.random_string, :count=>rand(23) + 1, :page_id=>@instance.id)
  end

  # sorts by count (ascending) and then by word (asciibetically)
  def test_word_count_sort

    pg = Page.new
    pg[:url] = 'http://techmeme.com'
    assert_equal true, pg.save
    a = WordCount.new(:word=>"a", :count=>1, :page_id=>pg.id)
    assert_equal true, a.save
    b = WordCount.new(:word=>"b", :count=>1, :page_id=>pg.id)
    assert_equal true, b.save
    c = WordCount.new(:word=>"c", :count=>23, :page_id=>pg.id)
    assert_equal true, c.save

    arr = [a,b,c].sort

    assert_same(arr[0],c)
    assert_same(arr[1],a) # sorts first by count, THEN by word
    assert_same(arr[2],b)

  end

  def test_most_common_word

    me = push_my_family 0

    assert_same @instance.most_common_word, me, "I should be the most common since I'm 38."

  end

  def push_my_family( idx )

    jpn = WordCount.new(:word=>"jason", :count=>38, :page_id=>@instance.id)
    smn = WordCount.new(:word=>"shelley", :count=> 37, :page_id=>@instance.id)
    emn = WordCount.new(:word=>"elida", :count=>7, :page_id=>@instance.id)
    rpn = WordCount.new(:word=>"ruby", :count=>5, :page_id=>@instance.id)
    pdn = WordCount.new(:word=>"peter", :count=>2, :page_id=>@instance.id)

    assert_equal true, jpn.save & smn.save & emn.save & rpn.save & pdn.save

    @instance.push smn
    @instance.push jpn
    @instance.push emn
    @instance.push rpn
    @instance.push pdn

    [jpn,smn,emn,rpn,pdn][idx]

  end

  def test_least_common

    pete = push_my_family 4

    assert_same(@instance.least_common_word, pete, "Pete's the least.")

  end

  def test_delete_least_common

    ruby = push_my_family 3

    @instance.delete_least_common

    assert_same(@instance.least_common_word, ruby)

  end

  def test_find_by_id

    actual = Page.find 1

    assert_not_nil actual
    assert_equal 'http://jasonnerothin.com/app/index.html', actual[:url]
    assert_equal 1, actual[:id]
    assert_equal Set.new(), actual.word_counts()

  end


end

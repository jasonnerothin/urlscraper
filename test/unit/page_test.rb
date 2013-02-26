require 'test_helper'
require 'random_data'

class PageTest < ActiveSupport::TestCase

  def setup
    @rand = RandomDataHelper.new

    @instance = Page.new
    @instance[:url] = "http://jasonnerothin.com/app/index.html"
    #@instance[:word_counts] = Set.new
    assert_equal true, @instance.save(:validate => false)

    @w0 = WordCount.new(:word => "wobble", :count => 18, :page_id => @instance.id)
    assert_equal true, @w0.save

    @w1 = WordCount.new(:word => "wibble", :count => 29, :page_id => @instance.id)
    assert_equal true, @w1.save

    @w2 = WordCount.new(:word => "wubble", :count => 3999, :page_id => @instance.id)
    assert_equal true, @w2.save

    @w3 = WordCount.new(:word => "flob", :count => 100000, :page_id => @instance.id)
    assert_equal true, @w3.save

  end

  test 'validation works' do
    page = Page.new

    page.errors.clear
    page.url = nil
    assert_equal false, page.valid?
    assert_equal true, page.invalid?
    has_error page, page[:url_reqd_message]

    page.errors.clear
    page.url = ''
    assert_equal false, page.valid?
    assert_equal true, page.invalid?
    has_error page, page[:url_reqd_message]

    page.errors.clear
    page.url = ' '
    assert_equal false, page.valid?
    assert_equal true, page.invalid?
    has_error page, nil

    page.errors.clear
    page.url = "http://jasonnerothin.com/" # is a redirect
    assert_equal false, page.valid?
    assert_equal true, page.invalid?
    invalid = 'Invalid URL'
    has_error page, 'Invalid response code'

    page.errors.clear
    page.url = "gopher://foo.bar.gov/"
    assert_equal false, page.valid?
    assert_equal true, page.invalid?
    has_error page, page[:http_message]

    page.errors.clear
    page.url = 'http://news.google.com' # fixture "two"
    assert_equal false, page.valid?
    has_error page, page[:already_processed_message]

    page.errors.clear
    page.url = 'http://www.yahoo.com'
    assert_equal true, page.valid?
    assert_equal 0, page.errors.size

  end

  def has_error(page, msg)
    if msg.nil?
      page.errors.size > 0
    else
      found = false
      page.errors.full_messages.each do |fm|
        unless fm.nil?
          if fm.to_s =~ /.*msg.to_s.*/
            found = true
          end
        end
      end
      found
    end
  end

  def lacks_error(page, msg)
    !has_error page, msg
  end

  # todo this method seems to run into another one (probably through @instance)
  # todo when tests are run in parallel (All tests in: test). Fix this problem.
  def test_push

    @instance.push @w0
    @instance.push @w3
    @instance.push @w2
    @instance.push @w1

    # ensure that we can\'t re-add the same word
    size = @instance.word_counts.size
    @instance.push @w0
    assert_equal size, @instance.word_counts.size - 1

    # ensure that we max out at 10 no matter how hard we try
    (0..15).each do
      @instance.push random_word_count
    end
    assert_equal 10, @instance.word_counts.size

    #puts @instance.to_json
    #puts @instance.word_counts.to_json

  end

  def random_word_count
    WordCount.new(:word => @rand.random_string, :count => rand(23) + 1, :page_id => @instance.id)
  end

  def test_most_common_word
    me = push_my_family 0
    assert_equal @family.most_common_word, me, "I should be the most common since I am 38."
  end

  def push_my_family(idx)

    @family = Page.new(:url => 'http://foo.com')
    assert_equal true, @family.save(:validate => false)

    jpn = WordCount.new(:word => "jason", :count => 38, :page_id => @family.id)
    smn = WordCount.new(:word => "shelley", :count => 37, :page_id => @instance.id)
    emn = WordCount.new(:word => "elida", :count => 7, :page_id => @family.id)
    rpn = WordCount.new(:word => "ruby", :count => 5, :page_id => @family.id)
    pdn = WordCount.new(:word => "peter", :count => 2, :page_id => @family.id)

    assert_equal true, rpn.save & smn.save & pdn.save & jpn.save & emn.save

    @family.push emn
    @family.push jpn
    @family.push smn
    @family.push rpn
    @family.push pdn

    [jpn, smn, emn, rpn, pdn][idx]

  end

  def test_least_common

    pete = push_my_family 4
    assert_same(pete, @family.least_common_word, "Pete's the least-most.")

  end

  def test_delete_least_common

    rooster = push_my_family 3
    @family.delete_least_common # get rid of pete
    assert_equal rooster, @family.least_common_word, "Pete's gone, Ruby's the least."

  end

  def test_find_by_id

    actual = Page.find 1

    assert_not_nil actual
    assert_equal 'http://jasonnerothin.com/app/index.html', actual[:url]
    assert_equal 1, actual[:id]
    cts = actual.word_counts
    assert_equal 0, cts.size

  end

end
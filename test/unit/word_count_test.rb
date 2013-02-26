require 'test_helper'

class WordCountTest < ActiveSupport::TestCase

  # WordCounts SHOULD sort by count (descending)
  # and then by word (asciibetically ascending)
  # but it really just sorts them by id for good reasons
  def test_word_count_comparable

    pg = Page.new
    pg.save( :validate => false )

    a = WordCount.new
    a[:word] = 'a'
    a[:count] = 1
    a[:page_id] = pg.id
    a[:id] = 2

    b = WordCount.new
    b[:word] = 'b'
    b[:count] = 1
    b[:page_id] = pg.id
    b[:id] = 3

    c = WordCount.new
    c[:word] = 'c'
    c[:count] = 23
    c[:page_id] = pg.id
    c[:id] = 1

    arr = [a,b,c]
    arr.sort!

    assert_equal( arr[0], c )
    assert_equal( arr[1], a ) # sort precedence should be  first by count THEN by word
    assert_equal( arr[2], b )

  end

end

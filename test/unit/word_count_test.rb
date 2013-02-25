require 'test_helper'

class WordCountTest < ActiveSupport::TestCase

  # WordCounts sort by count (descending) and then by word (asciibetically ascending)
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
    s = Set.new( arr )
    s.to_a.sort!

    assert_equal( s[0], c )
    assert_equal( s[1], a ) # sort precedence should be  first by count THEN by word
    assert_equal( s[2], b )

  end

end

require 'test_helper'

class WordCountTest < ActiveSupport::TestCase

  def before
    @one = WordCount.find 1
    @two = WordCount.find 2
    @three = WordCount.find 3
  end

  test 'word counts sort correctly' do
    arr = [@two, @three, @one]
    arr.sort

    assert_same arr[0], @three
    assert_same arr[1], @two
    assert_same arr[2], @one
  end

end

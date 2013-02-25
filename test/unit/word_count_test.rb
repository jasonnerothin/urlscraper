require 'test_helper'

class WordCountTest < ActiveSupport::TestCase

  def before
    @one = WordCount.find 1
    @two = WordCount.find 2
    @three = WordCount.find 3
  end

end

require "test/unit"
require "random_data"

class RandomDataHelperTest < Test::Unit::TestCase

  def setup
    @instance = RandomDataHelper.new()
  end

  def test_random_string
    # basic sanity
    actual = @instance.random_string
    assert_not_nil(actual, "want a real string")
    assert_equal(actual.length, 10, "default length is 10")

    # a little over-board since this format isn't really a requirement,
    # but it's always good to do things deliberately
    cnt = 0
    actual.each_byte do |ch|
      if cnt % 2 == 0
        validate 65, ch
      else
        validate 97, ch
      end
      cnt = cnt + 1
    end

    # test we get the right length, when we provide the arg
    len = 4
    actual = @instance.random_string len
    assert_equal actual.length, len

  end

  def test_random_char
    # test lower case
    (0..25).each {
      actual = random_char_test true
      validate 97, actual
    }
    # test upper case
    (0..25).each {
      actual = random_char_test false
      validate 65, actual
    }
  end

  def validate(lower_bound, char)
    assert_equal(char >= lower_bound, true, "Should be greater than or equal to #{lower_bound}, but was #{char}.")
    assert_equal(char <= lower_bound + 26, true, "Should be less than or equal to #{lower_bound + 26}, but was #{char}.")
  end

  def random_char_test(lower)
    actual = @instance.random_char lower
    actual[0]
  end

end
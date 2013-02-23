# A class for cranking out test data (most importantly random strings)
class RandomDataHelper

  # Add more helper methods to be used by all tests here...
  def random_string(len = 10)
    str = ""
    (1..len).each { |i|
      ch = random_char i.even? # alternate case to make it look "testy"
      str = str + ch
    }
    str
  end

  # prints a random alpha character lowercase by default
  # set lower to false for uppper case
  def random_char(lower = true)
    random_printable_char( lower )
  end

  # returns a-z or A-Z, depending upon the value of lower
  def random_printable_char(lower = true)
    ch = rand(26)
    if lower
      (ch + 97).chr
    else
      (ch + 65).chr
    end
  end

end
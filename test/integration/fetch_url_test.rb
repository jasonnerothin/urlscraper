require "test/unit"
require "app/helpers/fetch_url"

class FetchUrlTest < Test::Unit::TestCase

  def setup
    @url = "http://jasonnerothin.com/app/index.html"

    @instance = FetchUrl.new
  end

  def test_fetch
    a_link = "https://github.com/jasonnerothin/angular-phonecat"

    actual = @instance.fetch @url

    assert( actual.body.index(a_link) > 0, "The github link #{a_link} should be embedded in the source of #@url." )
  end

  def test_check_link

    a_link_that_redirects = "http://jasonnerothin.com"
    actual = @instance.check_link a_link_that_redirects
    assert_not_nil actual
    assert_equal false, actual

    a_link = "http://news.google.com"
    actual2 = @instance.check_link a_link
    assert_not_nil actual2
    assert_equal true, actual2

  end

end
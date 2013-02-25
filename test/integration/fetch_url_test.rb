require "test/unit"
require "app/helpers/fetch_url"

class FetchUrlTest < Test::Unit::TestCase

  def setup
    @url = "http://jasonnerothin.com/app/index.html"

    @instance = FetchUrl.new()
  end

  def test_fetch
    aLink = "https://github.com/jasonnerothin/angular-phonecat"

    actual = @instance.fetch(@url)

    assert( actual.body.index(aLink) > 0, "The github link #{aLink} should be embedded in the source of #{@url}." )
  end

  def test_check_link

    aLinkThatRedirects = "http://jasonnerothin.com"
    actual = @instance.check_link aLinkThatRedirects
    assert_not_nil actual
    assert_equal false, actual

    aLink = "http://news.google.com"
    actual2 = @instance.check_link aLink
    assert_not_nil actual2
    assert_equal true, actual2

  end

end
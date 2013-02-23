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

end
require "net/http"

class FetchUrl

  # grabs the entire contents of some URI and returns it as a string
  # pretty error-prone, but good enough for now...
  def fetch( url )
    raise("URL is required for a fetch to work.") if url.nil?
    Net::HTTP.get_response(URI.parse(url))
  end

  # checks that a url is reachable and has a
  # successful (and non-empty) response code
  def check_link(url)
    begin
      response = fetch(url)
      code = Integer(response.code)
      code > 199 && code < 300 && code != 204
    rescue
      false
    end
  end

end
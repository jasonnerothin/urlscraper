require "net/http"

class FetchUrl

  # grabs the entire contents of some URI and returns it as a string
  # pretty error-prone, but good enough for now...
  def fetch( url )
    raise("URL is required for a fetch to work.") if url.nil?
    Net::HTTP.get_response(URI.parse(url))
  end

end
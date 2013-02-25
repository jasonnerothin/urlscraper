class UrlChecker < ActiveModel::Validator
  def validate(page)
    fido = FetchUrl.new
    url = page[:url]
    unless fido.check_link url
      response = fido.fetch url
      page.errors[:base] << "Invalid response code %(response.code) for URL %(url)."
    end
  end
end

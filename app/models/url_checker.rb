class UrlChecker < ActiveModel::Validator
  def validate(page)
    bad_news = false
    fido = FetchUrl.new
    url = page[:url]
    begin
      unless fido.check_link url
        bad_news = true
      end
    rescue
      bad_news = true
    end
    if bad_news
      #response = fido.fetch url
      page.errors[:base] << "Invalid response for URL %(url)."
    end
  end
end

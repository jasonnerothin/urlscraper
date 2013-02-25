# A bunch of methods for html and string munging.
class PageProcessor

  def initialize
    @delimiters = %W{. \n \t / \\ : ; ? - ~ ( ) [ ] { } " _ = + ^ % $ @ ! 1 2 3 4 5 6 7 8 9 0}
  end

  # replaces common delimiters with single spaces
  def replace_delimiters(page_source)
    raise("Error: empty page source!") if page_source.nil? || page_source.empty?
    source = page_source
    @delimiters.each do |delim|
      source.gsub!(delim, " ")
    end
    strip_consecutive_spaces(source)
  end

  # get rid of consecutive spaces so that we don't end up tokenizing out a bunch of
  # empty strings
  def strip_consecutive_spaces(ps0)
    ps1 = nil
    until ps0.gsub!("  ", " ").nil?
      ps1 = ps0
    end
    ps1.strip! unless ps1.nil?
  # else
    ps0
  end

  # replaces html tags, endlines, and tabs (or xml for that matter) with single spaces
  def replace_tags(page_source)
    raise("Error: empty page source!") if page_source.nil? || page_source.empty?
    ps0 = page_source.gsub!(/(<[^>]*>)|\n|\t/s) { " " }
    strip_consecutive_spaces(ps0)
  end

  # tokenizes a web page into its word contents
  def tokenize(page_source)
    raise("Error: empty page source!") if page_source.nil? || page_source.empty?
    body_content = replace_tags page_source
    cleaned_up = replace_delimiters body_content
    cleaned_up.split(" ")
  end

  # returns a map of the word count for each word on the page
  def process_page(page_source)
    raise("Error: empty page source!") if page_source.nil? || page_source.empty?
    word_map = nil
    tokenize(page_source).each do |word|
      word_map = {word => 1} if word_map.nil?
      if word_map.has_key? word
        word_map[word] = word_map[word] + 1
      else
        word_map[word] = 1
      end
    end
    word_map
  end

end
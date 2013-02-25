require "json"

# A model class that keeps track of word counts for a text resource mapped by a URL.
# A web page is a quite obvious example.
class Page < ActiveRecord::Base

  attr_accessible @url, @word_counts

  has_many :word_counts

  def word_counts
    init_word_counts
    @word_counts
  end

  def after_initialize
    init_word_counts
    @url = ''
  end

  validates :url, :presence => true
  validates :url, :format => {:with => /^http:\/\/*/, :message => "URL must start with 'http://'."}
  validates :url, :uniqueness => { :case_sensitive => false, :message => "URL %(url) has already been processed."}
  validates_with UrlChecker

  # Attempt to push a new WordCount into the set.
  # This attempt is only successful if the WordCount is
  # higher than the least common word currently in the set.
  # Note that this method is potentially "lossy" (because
  # words with identical frequency can be dropped off the
  # list.) This is a reasonable trade-off for the smaller
  # memory footprint. We expect most pages to have a
  # normal distribution, so the likelihood is that the
  # less common words will crowd each other out. And
  # the uncommon words are implicitly the ones we're
  # disinterested in.
  def push(word)
    init_word_counts
    if self.word_counts.size < 10
      self.word_counts << word
    else # 10 words already TODO this looks wrong - test it
      unless least_common_word.nil?
        if word[:count] > least_common_word[:count]
          delete_least_common
          self.word_counts << word
        end
      end
    end
    #@words.sort # don't want to take the performance hit for large pages
  end

  # the most common word we are keeping track of
  def most_common_word
    if word_counts.size == 0
      'Page not processed (or no content)'
    else
      word_counts.sort.to_a[0]
    end
  end

  def process_url
    map_words_on_page.each do |word, count|
      wc = WordCount.new(:word=>word, :count=>count, :page_id => object_id)
      push wc # note no save here, since we only want to keep 10
    end
  end

  # returns the least common word count
  # or nil if there are no recorded words
  # yet
  # public only for testing
  def least_common_word
    sz = word_counts.size
    if sz > 0
      word_counts.sort.to_a[sz-1]
    else
      nil
    end
  end

  # deletes the least common word in the set
  # public only for testing
  def delete_least_common
    lc = least_common_word
    @word_counts.delete(lc) unless lc.nil?
  end

  private

  # returns a map from word to count
  def map_words_on_page
    fetcher = FetchUrl.new
    processor = PageProcessor.new
    page_content = fetcher.fetch(self[:url]).body
    processor.process_page page_content
  end

  def init_word_counts
    if @word_counts.nil?
      @word_counts = Set.new
    end
  end

end


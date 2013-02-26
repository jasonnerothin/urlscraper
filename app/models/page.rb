require "json"

# A model class that keeps track of word counts for a text resource mapped by a URL.
# A web page is a quite obvious example.
class Page < ActiveRecord::Base

  attr_accessible :url, :word_counts, :url_reqd_message, :http_message, :already_processed_message

  has_many :word_counts

  def after_initialize
    self[:url] = 'http://'
    @url_reqd_message = 'URL required'
    @http_message = "URL must start with 'http://'."
    @already_processed_message = 'URL %(url) has already been processed.'
  end

  validates :url, :presence => { :message =>  @url_reqd_message }
  validates :url, :format => {:with => /^http:\/\/.*/, :message => @http_message }
  validates :url, :uniqueness => { :case_sensitive => false, :message => @already_processed_message }
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
  #
  # todo push these onto a real stack (field that's not part of the ActiveRecord)
  # todo to minimize on db problems...
  def push(word)
    if self.word_counts.size < 10
      self.word_counts = ( self.word_counts << word )
    else # 10 words already
      unless least_common_word.nil?
        if word[:count] > least_common_word[:count]
          delete_least_common
          self.word_counts = ( self.word_counts << word )
        end
      end
    end
    # @word_counts.sort <- don't want to take the performance hit for large pages
  end

  # returns the least common word count
  # or nil if there are no recorded words
  # yet
  # public only for testing
  def least_common_word
    sz = word_counts.size
    if sz > 0
      sort_word_counts
      word_counts.to_a[sz-1]
    else
      nil
    end
  end

  # the most common word we are keeping track of
  def most_common_word
    if word_counts.size == 0
      WordCount.new(:word=>'n/a',:count=>0)
    else
      sort_word_counts
      word_counts.to_a[0]
    end
  end

  # deletes the least common word in the set
  # public only for testing
  def delete_least_common
    lc = least_common_word
    self.word_counts.delete(lc) unless lc.nil? || self.word_counts.nil?
  end

  # saves the page down and then
  # pulls info from the url to fill up with
  def save_then_process!
    success = false
    begin
      if save!
         success = true
      end
    rescue
      success = false
    end
    process_url if success
    success
  end

  private

  # returns a map from word to count
  def map_words_on_page
    fetcher = FetchUrl.new
    page_content = fetcher.fetch(self[:url]).body

    processor = PageProcessor.new
    processor.process_page page_content
  end

  def sort_word_counts
    word_counts.sort!{ |y,x|
      result = x.nil_compare y, :count
      unless result != 0
        result = x.nil_compare y, :word
        unless result != 0
          result = x <=> y
        end
      end
      result
    }
  end

  # pull information back from the url and
  # calculate the 10 most common words
  def process_url
    map = map_words_on_page
    map.each do |word, count|
      wc = WordCount.new(:word=>word, :count=>count, :page_id => object_id)
      push wc # todo pull the push/stack functionality out of Page to minimize db calls
    end
  end

  # deprecated
  def save_everything
    success = true
    now = DateTime.now
    self[:updated_at] = now
    if self.update
      word_counts.each do | wc |
        wc[:page_id] = page.id
        wc[:created_at] = now
        wc[:updated_at] = now
        unless wc.save
          success = false
        end
      end unless word_counts.nil?
    else
      success = false
    end
    success
  end

end
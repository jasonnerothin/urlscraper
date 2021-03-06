class PageController < ApplicationController

  #protect_from_forgery

  # wipe out to start from scratch
  def annihilate
    @pages = Page.all
    @pages.each do |pg|
      pg.destroy
    end
    @wc = WordCount.all
    @wc.each do |wc|
      wc.destroy
    end
    render 'page/all-gone'
  end

  def index
    clean_up_invalid_pages
    clean_up_invalid_word_counts
    @pages = Page.all
    respond_to do |format|
      format.html
    end
  end

  # render a form with a single url on it
  def new
    @page = Page.new
    @page.created_at = DateTime.now
    @page.updated_at = DateTime.now
    @page[:url] = 'http://' unless !@page[:url].nil? || @page[:url].empty? # save the user the hassle
    respond_to do |format|
      begin
        if @page.save(:validate => false) # want to skip url validation
          format.html
          format.json { render :json => @page }
        else
          not_found # todo change to 500 analog of this method
        end
      rescue
        format.html # todo 500 page
      cat e
        format.html # todo 500 page
      end
    end
  end

  # scrape the url (if valid) and calculate common
  # words on it
  def update
    @page = Page.find params[:page][:id]
    @page.url = params[:page][:url]
    if @page.save_then_process!
      redirect_to page_show_url(:page_id => @page.id)
    else
      render :new
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not found')
  end

  #show details about a single page, or
  #redirect to an error page if necessary
  def show
    id = params[:page_id]
    id ||= @_params[:id]
    @page = Page.find id
    respond_to do |format|
      format.html # render 'page/show/?id=' + id
      format.json { render :json => @page, :status => :ok, :location => @page }
    end
  end

  private

  # happens when people migrate away from the page/new form without submitting
  def clean_up_invalid_pages
    all = Page.all
    unless all.nil? || all.empty?
      all.each do |pg|
        unless pg.valid?
          pg.destroy
        end
      end
    end
  end

  def clean_up_invalid_word_counts
    all = WordCount.find_all_by_page_id(nil)
    unless all.nil? || all.empty?
      all.each do |wc|
        wc.destroy
      end
    end
  end

end
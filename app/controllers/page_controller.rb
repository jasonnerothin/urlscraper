class PageController < ApplicationController

  #protect_from_forgery

  def index
    @pages = Page.all
    #@pages.each do |pg|
    #  pg.destroy
    #end
    render 'page/index'
  end

  # render a form with a single url on it
  def new
    @page = Page.new()
    @page[:url] = "http://news.google.com" # temp
    @page.init
    @page.created_at = DateTime.now
    @page.updated_at = DateTime.now
    respond_to do |format|
      begin
        if @page.save
          format.html # new.html.erb
          format.json { render :json => @page }
        else
          format.html { render :action => :new }
          format.json { render :json => @page, :status => :unprocessable_entity }
        end
      rescue
        x = 1
        format.html
      cat e
        x = 2
        format.html
      end
    end
  end

  # scrape the url (if valid) and calculate common
  # words on it
  def update

    @page = Page.find params[:page][:id]
    @page.url = params[:page][:url]
    word_count(@page).each do |word, count|
      wc = WordCount.new(word, count)
      @page.push wc
    end

    respond_to do |format|
      begin
        if @page.update!
          format.html { redirect_to(@page, :notice => 'Page successfully created.') }
          format.json { render :json => @page, :status => :created, :location => @page }
        else
          format.html { render :action => :new }
          format.json { render :json => @page.errors, :status => :unprocessable_entity }
        end
      rescue
        render :action => :update, :status => :unprocessable_entity, :notice => 'Invalid page: Save attempt failed.'
      end

    end

  end

  def word_count(page)
    fetcher = FetchUrl.new
    processor = PageProcessor.new
    processor.process_page(fetcher.fetch(page[:url]).body)
  end

  # show details about a single page, or
  # redirect to an error page if necessary
  def show
    @done = false # todo i would rather not use a member variable
    id = params[:id]
    if id.nil?
      @done = true
      render 'page/noresult'
    end

    begin
      @page = Page.find id unless @done
    rescue
      @done = true
      render 'page/noresult' unless @done
    end
    unless @done
      respond_to do |format|
        format.html # render 'page/show/?id=' + id
        format.json { render :json => @page, :status => :ok, :location => @page }
      end
    end
  end

end

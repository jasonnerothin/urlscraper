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
    @page[:url] = 'http://' # save the user the hassle
    respond_to do |format|
      begin
        if @page.save(:validate => false) # want to skip url validation
          format.html
          format.json { render :json => @page }
        else
          format.html # { redirect_to root } # really should just error
          format.json { render :json => @page, :status => :unprocessable_entity }
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
    @page.save!
    @page.process_url
    render :show
  end

  def not_found
    raise ActionController::RoutingError.new('Not found')
  end

  #show details about a single page, or
  #redirect to an error page if necessary
  def show
    #success = false
    id = params[:page_id]
    @page = Page.find id
    WordCount.find_all_by_page_id(id).each do |wc|
      @page.push wc
    end
    success = true
    if success && !id.nil?
      respond_to do |format|
        format.html # render 'page/show/?id=' + id
        format.json { render :json => @page, :status => :ok, :location => @page }
      end
    else
      render 'page/no-result'
    end
  end

end
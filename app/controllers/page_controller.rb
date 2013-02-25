class PageController < ApplicationController

  #protect_from_forgery

  # wipe out to start from scratch
  def annihilate
    @pages = Page.all
    @pages.each do |pg|
      pg.destroy
    end
    render 'page/all-gone'
  end

  def index
    @pages = Page.all
    render 'page/index'
  end

  # render a form with a single url on it
  def new
    @page = Page.new
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
    @page.process_url

    respond_to do |format|
      begin
        if save_page @page # we save off the word counts in this method
          format.html { render :action => :show, :id => @page.id } # show the details
          format.json { render :json => @page, :status => :created, :location => @page }
        else
          format.html { render :action => :new }
          format.json { render :json => @page.errors, :status => :unprocessable_entity }
        end
      rescue
        render :action => :not_found
      end
    end
  end

  def not_found
    raise ActionController::RoutingError.new('Not found')
  end

  def save_page(page)
    success = true
    now = DateTime.now
    page.updated_at = now
    #if page.update
      page.word_counts.each do | wc |
        wc[:page_id] = page.id
        wc[:created_at] = now
        wc[:updated_at] = now
        unless wc.save
          success = false
        end
      end
    #else
    #  success = false
    #end
    success
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

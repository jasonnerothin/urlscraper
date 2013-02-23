class PageController < ApplicationController
  #protect_from_forgery

  def index
    @pages = Page.all
    render 'page/index'
  end

  def form
    render 'page/form'
  end

  # show details about a single page, or
  # redirect to an error page if necessary
  def detail
    rendered = false
    @id = params[:id]
    if @id.nil?
      render 'page/noresult'
      rendered = true
    end
    begin
      @page = Page.find id unless rendered
    rescue
      render 'page/noresult' unless rendered
      rendered = true
    end
    respond_to do |format|
      format.html render 'page/detail'
      format.json :json => @post
    end unless rendered
  end

end

class PageController < ApplicationController
  #protect_from_forgery
  def index
    @pages = Page.all
    render 'page/index'
  end
  def form
    render 'page/form'
  end
  def detail
    @page = Page.find_by()
    render 'page/detail'
  end
end

require 'test_helper'

class PageControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get error page when no id supplied" do

    actual = get :detail
    assert_response :success
    @page = actual.body
    assert @page.index( "id required") > -1

  end

  test "should get an error page when no record found" do

    actual = get :detail, :id => 2
    assert_response :success
    @page = actual.body
    assert @page.index("does not correspond to a Page") > -1

  end


end

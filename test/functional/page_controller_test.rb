require 'test_helper'

class PageControllerTest < ActionController::TestCase

  # index action

  @idx_content = 'Url Word Counter'

  test 'index renders for root' do
    actual get '/'

    assert_response :success
    has_content actual.body, @idx_content
  end

  test 'index renders' do
    actual = get :index

    assert_response :success
    has_content actual.body, @idx_content
  end

  # new action

  test 'new should render' do
    page = get :new

    assert_response :success
    has_content page.body, 'Enter a URL'
    has_content page.body, '<div class="url_entry">'
  end

  # show action

  test 'show should get error message when no id supplied' do
    page = get :show

    assert_response :success
    has_content page.body,'id required'
  end

  def has_content( body_content, msg )
    idx = body_content.index( msg )
    assert_not_nil idx
    assert_not_equal idx, -1
  end

  test 'show should get an error message when no record found' do
    page = get :show, :id => 20

    assert_response :success
    has_content page.body, 'does not correspond to a Page'
  end

  test 'show has no words when Page has no words' do

    page = get :show, :id => 1 # fixture one
    assert_response :success
    has_content page.body, 'No words!'
  end

  test 'show has words when Page has words' do

    page = get :show, :id => 2 # fixture two
    assert_response :success
    has_content page.body, 'word:'
    has_content page.body, 'alpha'
    has_content page.body, 'count:'
    has_content page.body, '23'

  end

end

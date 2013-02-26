require 'test_helper'

class PageControllerTest < ActionController::TestCase

  # new action

  test 'new should render' do
    page = get :new

    assert_response :success
    has_content page.body, 'Enter a URL'
    has_content page.body, '<div class="url_entry">'
  end

  private

  def has_content( body_content, msg )
    idx = body_content.index( msg )
    assert_not_nil idx
    assert_not_equal idx, -1
  end

end

# encoding: utf-8

module WebUtilities

  def cookie_manager
    case Capybara.current_session.driver
      when Capybara::Selenium::Driver
        cookie_manager = page.driver.browser.manage
      else
        raise "no cookie-setter implemented for driver #{Capybara.current_session.driver.class.name}"
    end
    cookie_manager
  end

  def get_cookie(name = 'access_token')
    cookie_manager.cookie_named(name)
  end

  def set_cookie(name, value)
    cookie_manager.add_cookie(:name => name, :value => value)
  end

  def delete_cookie(name)
    cookie_manager.delete_cookie(name)
  end

  def delete_all_cookies
    reset_session
  end

  def reset_session!
    Capybara.current_session.reset_session!
  end

  def mouse_over(element)
    if Capybara.current_session.driver == Capybara::Selenium::Driver
      element.native.location_once_scrolled_into_view
      page.driver.browser.action.move_to(element.native).perform
    end
    element.hover
  end

  def maximize_window
    page.driver.browser.manage.window.maximize
  end

  def resize_window(x, y)
    page.driver.browser.manage.window.resize_to(x, y)
  end

  def refresh_current_page
    page.driver.browser.navigate.refresh
    current_page.wait_until_header_visible(10)
  end

  def go_back
    page.evaluate_script('window.history.back()')
  end

end

module BlinkboxWebUtilities
  def set_start_cookie_accepted
    visit('/') unless current_path == '/'
    set_cookie('start_cookie_accepted', 'true')
    visit('/')
  end

  def delete_access_token_cookie
    delete_cookie('access_token')
  rescue
    puts 'A problem occurred while deleting the access_token cookie!'
  end

  def assert_page_new_window(page_name)
    new_window = page.driver.browser.window_handles.last
    page.within_window new_window do
      assert_page(page_name)
      page.driver.browser.close
    end
  end

  def assert_browser_count(count)
    browser_windows = page.driver.browser.window_handles
    expect(browser_windows.count).to eq(count), "expected #{count} browser windows to be opened, got #{browser_windows.count}"
  end

end

World(WebUtilities)
World(BlinkboxWebUtilities)
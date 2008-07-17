require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../ratings_extension'

class PageTest < Test::Unit::TestCase
  def test_handles_stale_exception
    Page.create!(:title => 'Home', 
                 :slug => '/', 
                 :breadcrumb => 'home', 
                 :status => Status[:published])
    RatingsExtension.activate
    p1 = Page.find(1)
    p2 = Page.find(1)

    p1.add_rating("1", "token")
    p1.update_average_rating
    
    p2.add_rating("2", "token2")
    p2.update_average_rating
    p1.reload
    assert_equal "1.5", p1.average_rating.to_s
  end 
end
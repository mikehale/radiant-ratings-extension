require 'spec_helper'

describe RatingsHelper do
  dataset :pages

  should_calculate_rating_image_width('#rating_image_width') do
    helper.rating_image_width(@page).should == @expected_width
  end

  should_render_vote_description('<r:vote_description />') do
    helper.vote_description(@page).should == @expected_description
  end
end

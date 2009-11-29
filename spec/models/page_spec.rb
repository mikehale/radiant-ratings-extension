require 'spec_helper'

describe Page do
  dataset :pages

  it 'should handle a stale object error' do
    p1 = pages(:home)
    p2 = Page.find(p1.id)

    p1.add_rating("1", "token")
    p1.update_average_rating

    p2.add_rating("2", "token2")
    p2.update_average_rating
    p1.reload

    p1.average_rating.should == 1.5
  end
end
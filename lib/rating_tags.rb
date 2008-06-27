module RatingTags
  include Radiant::Taggable
  
  tag 'rating' do |tag|
    tag.locals.rating = tag.locals.page.average_rating
    tag.locals.max_points = (tag.attr["max"] || 5).to_i
    tag.expand
  end
  
  tag 'rating:average' do |tag|
    if multiply_by = tag.attr['multiply_by']
      tag.locals.rating * multiply_by.to_f
    else
      tag.locals.rating
    end
  end
  
  tag 'rating:votes' do |tag|
    tag.locals.page.ratings.count.to_s
  end
  
  tag 'rating:form' do |tag|
    %(<form action="/pages/#{tag.locals.page.id}/ratings" method="post" id="rating_form">
      #{tag.expand}
    </form>)
  end
  
  tag 'rating:points' do |tag|
    tag.expand
  end
  
  tag 'rating:points:each' do |tag|
    r = []
    (1..(tag.locals.max_points)).each do |e|
      tag.locals.point_value = e
      r << tag.expand
    end
    r
  end
  
  tag 'rating:points:each:point_value' do |tag|
    tag.locals.point_value
  end
end
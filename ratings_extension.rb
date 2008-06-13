class RatingsExtension < Radiant::Extension
  version "1.0"
  description "Provides the ability to rank radiant pages."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.connect 'ratings/rate/:page_id/:rating', :controller => 'ratings', :action => 'rate'
    map.connect 'ratings/rating/:page_id', :controller => 'ratings', :action => 'rating'
  end
  
  def activate
    Page.send :include, RatingTags

    Page.class_eval do
      has_many :ratings

      def average_rating
        avg = Rating.average(:rating, :conditions => "page_id = #{id}")
        avg ? avg.round(2) : BigDecimal('0')
      end
      
      def add_rating(rating, rating_user_token)
        r = Rating.find(:first, :conditions => { :page_id => self.id, :user_token => rating_user_token })
        r = Rating.new(:page => self, :user_token => rating_user_token) unless r
        r.update_attributes(:rating => rating)
      end
    end
  end
  
  def deactivate
  end
  
end
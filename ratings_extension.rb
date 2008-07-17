class RatingsExtension < Radiant::Extension
  version "1.0"
  description "Provides the ability to rank radiant pages."
  url "http://terralien.com/"
  
  define_routes do |map|
    map.resources :ratings, :path_prefix => "/pages/:page_id"
  end
  
  def activate
    Page.send :include, RatingTags

    Page.class_eval do
      has_many :ratings

      def add_rating(rating, rating_user_token)
        r = Rating.find_or_initialize_by_page_id_and_user_token(self.id, rating_user_token)
        r.rating = rating
        r.save!
        
        update_average_rating
        ResponseCache.instance.expire_response(url) 
      end
      
      def update_average_rating
        set_average_rating
        begin
          self.save!
        rescue ActiveRecord::StaleObjectError => e
          self.reload
          set_average_rating
          self.save!
        end
      end
      
      protected
      
        def set_average_rating
          avg = Rating.average(:rating, :conditions => "page_id = #{id}")
          self.average_rating = avg ? avg.round(2) : BigDecimal('0')
        end
    end
  end
  
  def deactivate
  end
  
end
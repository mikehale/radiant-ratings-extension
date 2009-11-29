class RatingsExtension < Radiant::Extension
  version "1.0"
  description "Provides the ability to rank radiant pages."
  url "http://terralien.com/"

  define_routes do |map|
    map.resources :ratings, :only => [:create], :path_prefix => "/pages/:page_id"
  end

  def activate
    Page.class_eval do
      include RatingTags
      include RatingsPageExtension
    end
  end

  def deactivate
  end

end
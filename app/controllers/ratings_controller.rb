class RatingsController < ApplicationController
  no_login_required
  skip_before_filter :verify_authenticity_token
    
  def create
    page.add_rating(params[:rating], rating_user_token)
    respond_to do |format|
      format.js {render :json => {:average => page.average_rating, :votes => page.ratings.count}}.to_json
      format.html {redirect_to page.url}
    end
  end

  private  
  
  def salt
    "-my-secret-#{Time.now}-"
  end
  
  def rating_user_token
    cookies[:rating_user_token] ||= Digest::SHA1.hexdigest(salt)
  end
  
  def page
    Page.find(params[:page_id])
  end
    
end

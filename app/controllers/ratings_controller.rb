class RatingsController < ApplicationController
  include RatingsHelper

  no_login_required
  skip_before_filter :verify_authenticity_token

  def create
    page.add_rating(params[:rating], rating_user_token)
    respond_to do |format|
      format.html { redirect_to page.url }
      format.js do
        render :json => {
          :average          => page.average_rating,
          :votes            => page.ratings.count,
          :vote_description => vote_description(page),
          :image_width      => rating_image_width(page)
        }
      end
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
    @page ||= Page.find(params[:page_id])
  end
  
end

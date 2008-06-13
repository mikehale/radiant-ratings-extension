class RatingsController < ApplicationController
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def rating
    render :text => %(#{page.average_rating})
  end
  
  def rate
    logger.debug(rating_user_token)
    page.add_rating(params[:rating], rating_user_token)
    render :text => "noop"
  end

  private  
  
  def salt(length=50)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    salt = ''
    length.downto(1) { |i| salt << chars[rand(chars.length - 1)] }
    salt
  end
  
  def rating_user_token
    if cookies[:rating_user_token].nil?
      token = Digest::SHA1.hexdigest(salt)
      cookies[:rating_user_token] = token
      token
    else
      cookies[:rating_user_token]
    end
  end
  
  def page
    Page.find(params[:page_id])
  end
    
end

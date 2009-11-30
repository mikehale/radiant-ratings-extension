require 'spec_helper'

describe RatingsController do
  dataset :pages

  def attributes(attr = {})
    { :page_id => pages(:home).id, :rating => 3 }.merge(attr)
  end

  def self.should_render_the_correct_response(format)
    if format == 'html'
      it "should redirect to the page being rated" do
        response.should redirect_to(pages(:home).url)
      end
    else
      it { should respond_with(:success) }

      it "should respond with json containing the page rating data" do
        ActiveSupport::JSON.decode(response.body).should == {
          'average'          => 3.0,
          'votes'            => 1,
          'vote_description' => '1 vote',
          'image_width'      => 90
        }
      end
    end
  end

  %w(html js).each do |format|
    context 'when there are no ratings' do
      before(:each) do
        Rating.count.should == 0
      end

      describe "on POST to :create with format = #{format}" do
        before(:each) do
          post :create, attributes(:format => format)
        end

        should_render_the_correct_response(format)

        it "should create a rating" do
          Rating.count.should == 1
          rating = Rating.first
          rating.rating.should == 3
          rating.page.should == pages(:home)
          rating.user_token =~ /\a[0-9a-f]{16}\z/
        end

        it "should update the page's average rating" do
          pages(:home).reload.average_rating.should == 3
        end

        it "should store the user_token in a cookie" do
          cookies[:rating_user_token].should == Rating.last.user_token
        end
      end
    end

    context 'when the user has already rated the page' do
      before(:each) do
        @user_token = Digest::SHA1.hexdigest('salt')
        cookies[:rating_user_token] = @user_token
        @rating = Rating.create!(attributes(:user_token => @user_token, :rating => 1))
        @rating_count = Rating.count
      end

      describe "on POST to :create with format = #{format}" do
        before(:each) do
          post :create, attributes(:format => format)
        end

        should_render_the_correct_response(format)

        it "should update the rating" do
          @rating.reload.rating.should == 3
        end

        it 'should not change the rating count' do
          Rating.count.should == @rating_count
        end

        it "should update the page's average rating" do
          pages(:home).reload.average_rating.should == 3
        end
      end
    end
  end
end
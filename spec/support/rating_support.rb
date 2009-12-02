module RatingSupport

  def self.included(base)
    base.extend ClassMethods
  end

  def mock_rating_count(count)
    ratings = mock('ratings')
    ratings.should_receive(:count).at_least(:once).and_return(count)
    @page.should_receive(:ratings).at_least(:once).and_return(ratings)
  end

  def mock_average_rating(rating)
    @page.should_receive(:average_rating).at_least(:once).and_return(rating)
  end

  module ClassMethods
    def with_config(config)
      before(:each) do
        config.each do |key, value|
          Radiant::Config["ratings.#{key}"] = value
        end
      end
    end

    def should_render_vote_description(description, &block)
      describe description do
        { 0 => 'votes', 1 => 'vote', 2 => 'votes' }.each do |count, term|
          expected = "#{count} #{term}"
          it "should render '#{expected}' when the count is #{count}" do
            @expected_description = expected
            @page = pages(:home)
            mock_rating_count(count)
            instance_eval(&block)
          end
        end
      end
    end

    def should_calculate_rating_image_width(description, &block)
      describe description do
        context 'with no configuration' do
          with_config('image_width' => nil, 'image_padding' => nil)

          { 4 => 120, 5 => 150, 2.2 => 70, 4.7 => 138 }.each do |rating, width|
            it "should return #{width} when the rating is #{rating}" do
              @expected_width = width
              @page = pages(:home)
              mock_average_rating(rating)
              instance_eval(&block)
            end
          end
        end

        context 'when image_width="15" and image_padding="3"' do
          with_config('image_width' => 15, 'image_padding' => 3)

          { 4 => 60, 5 => 75, 2.2 => 34, 4.7 => 69 }.each do |rating, width|
            it "should return #{width} when the rating is #{rating}" do
              @expected_width = width
              @page = pages(:home)
              mock_average_rating(rating)
              instance_eval(&block)
            end
          end
        end
      end
    end
  end
end
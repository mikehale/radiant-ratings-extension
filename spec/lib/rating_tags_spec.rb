require 'spec_helper'

describe RatingTags do
  dataset :pages

  before(:each) do
    @page = pages(:home)
  end

  context 'within <r:rating>' do
    def render(input, options = {})
      super("<r:rating#{%( max="#{options[:rating_max]}") if options[:rating_max]}>#{input}</r:rating>")
    end

    describe '<r:average />' do
      before(:each) do
        @page.should_receive(:average_rating).at_least(:once).and_return(4.2)
      end

      it "should render the page's average rating" do
        @page.should render('<r:average />').as('4.2')
      end

      it "should multiply by the value of the multiply_by attribute" do
        @page.should render('<r:average multiply_by="10"/>').as('42.0')
      end
    end

    describe '<r:votes />' do
      before(:each) do
        ratings = mock('ratings')
        ratings.should_receive(:count).and_return(7)
        @page.should_receive(:ratings).and_return(ratings)
      end

      it "should render the number of rating votes for this page" do
        @page.should render('<r:votes />').as('7')
      end
    end

    describe '<r:form />' do
      it "should render a form that posts to the rating action" do
        form_fragment = %(<form action="/pages/#{@page.id}/ratings" method="post")
        @page.should render('<r:form />').matching(/#{Regexp.escape(form_fragment)}/)
      end
    end

    context 'within <r:points:each>' do
      def render(input, options = {})
        super("<r:points:each>#{input}</r:points:each>", options)
      end

      it "should render the inner contents the same number of times as the rating tag's max attribute" do
        @page.should render('A', :rating_max => 12).as("A" * 12)
      end

      describe '<r:point_value />' do
        it "should render the point values" do
          @page.should render('<r:point_value /> ').as('1 2 3 4 5 ')
        end
      end

      describe '<r:if_average_greater>' do
        it 'should only render the inner content when the average is greater than the rating' do
          @page.stub!(:average_rating).and_return(3)
          @page.should render('A<r:if_average_greater> M </r:if_average_greater>Z').as(('A M Z' * 2) + ('AZ' * 3))
        end
      end

      describe '<r:if_average_less>' do
        it 'should only render the inner content when the average is less than the rating' do
          @page.stub!(:average_rating).and_return(3)
          @page.should render('A<r:if_average_less> M </r:if_average_less>Z').as(('AZ' * 3) + ('A M Z' * 2))
        end
      end
    end
  end
end
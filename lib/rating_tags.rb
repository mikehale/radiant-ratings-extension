module RatingTags
  include Radiant::Taggable
  
  tag 'rating' do |tag|
    page = tag.locals.page
    image_width = 25
    rating_id = "rating_#{page.id}"

    result = []
    result << star_rating_css
    result << %(
      <script type="text/javascript">

        function displayAverageRating() {
          new Ajax.Request('/ratings/rating/#{page.id}', {
            onSuccess: function(transport) {
              var averageRating = parseFloat(transport.responseText);
              $('#{rating_id}').setStyle({ width: (averageRating * #{image_width}) + 'px' });
            }
          });
        }
        
        function rate(newRating){
          new Ajax.Request("/ratings/rate/#{page.id}/" + newRating, {
            onSuccess: function() { displayAverageRating(); }
          });          
        }
        
        function observeRatings() {
          var stars = $$('.star-rating li:not([class=current-rating])');
          stars.each(function(star, index) {
            //This line should work but ends up always rating at 5... WHY?
            //newRating = star.select('a')[0].innerHTML;
            star.observe('click', function(event) { rate(index + 1); });
          });
        }

        
        Event.observe(window, 'load', function() { 
          displayAverageRating(); 
          observeRatings(); 
        });
      </script>
    )
    
    result << %(
    	<span class="inline-rating">
    	<ul class="star-rating">
    		<li id="#{rating_id}" class="current-rating" style="width:0px;"/>
    )
      range = (1..5)
      range.each {|e|
        result << %(<li><a href="javascript:void(0);" title="#{e} star out of #{range.max}" class="#{generate_class_name(e)}">#{e}</a></li>)
      }
    result << %(</ul></span>)
    
    result
  end
  
  private
  
  def generate_class_name(number)
    %w(one-star two-stars three-stars four-stars five-stars)[number-1]
  end
    
  def star_rating_css
    %(<style type="text/css">
    .star-rating,
    .star-rating a:hover,
    .star-rating .current-rating{
    	background: url(/images/star.gif) left -1000px repeat-x;
    }
    .star-rating{
    	position:relative;
    	width:125px;
    	height:25px;
    	overflow:hidden;
    	list-style:none;
    	margin:0;
    	padding:0;
    	background-position: left top;
    }
    .star-rating li{
    	display: inline;
    }
    .star-rating a, 
    .star-rating .current-rating{
    	position:absolute;
    	top:0;
    	left:0;
    	text-indent:-1000em;
    	height:25px;
    	line-height:25px;
    	outline:none;
    	overflow:hidden;
    	border: none;
    }
    .star-rating a:hover{
    	background-position: left bottom;
    }
    .star-rating a.one-star{
    	width:20%;
    	z-index:6;
    }
    .star-rating a.two-stars{
    	width:40%;
    	z-index:5;
    }
    .star-rating a.three-stars{
    	width:60%;
    	z-index:4;
    }
    .star-rating a.four-stars{
    	width:80%;
    	z-index:3;
    }
    .star-rating a.five-stars{
    	width:100%;
    	z-index:2;
    }
    .star-rating .current-rating{
    	z-index:1;
    	background-position: left center;
    }	

    /* for an inline rater */
    .inline-rating{
    	display:-moz-inline-block;
    	display:-moz-inline-box;
    	display:inline-block;
    	vertical-align: middle;
    }    
    </style>)
  end
  
end
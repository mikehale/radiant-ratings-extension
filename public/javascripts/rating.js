$(document).ready(function() {
  $('#rating_form button')
    .click(function() {
      $.post(
        $('#rating_form').attr('action') + '.js',
        { rating: this.value },
        function(data) {
          $('#rating_container .rating_average').each(function() {
            this.innerHTML = data.average;
          });

          $('#rating_container .rating_vote_description').each(function() {
            this.innerHTML = data.vote_description;
          });

          $('#rating_container .current_rating').each(function() {
            this.style.width =  data.image_width + 'px';
          });
        },
        "json"
      );

      return false;
    });
});
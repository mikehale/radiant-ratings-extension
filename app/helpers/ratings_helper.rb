module RatingsHelper
  def rating_image_width(page)
    star_image_width = (Radiant::Config['ratings.image_width'].blank? ? default_rating_config['image_width'] : Radiant::Config['ratings.image_width']).to_i
    star_image_padding = (Radiant::Config['ratings.image_padding'].blank? ? default_rating_config['image_padding'] : Radiant::Config['ratings.image_padding']).to_i
    inner_image_width = star_image_width - (2 * star_image_padding)

    rating = page.average_rating.to_f
    int_part = rating.floor
    fractional_part = rating - int_part

    width_for_int_part = (int_part * star_image_width)

    if fractional_part == 0
      width_for_int_part
    else
      width_for_int_part + star_image_padding + (fractional_part * inner_image_width).to_i
    end
  end

  def vote_description(page)
    count = page.ratings.count
    term = count == 1 ? 'vote' : 'votes'
    "#{count} #{term}"
  end

  private

  def default_rating_config
    @default_rating_config ||= begin
      yaml_file = File.join(RatingsExtension.root, "db", "config_defaults.yml")
      yaml = File.open(yaml_file) { |f| f.read }
      YAML.load(yaml)
    end
  end
end

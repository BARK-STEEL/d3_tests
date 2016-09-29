
def get_results_by_location
  if is_place_search?
    get_results_by_place
  end

  # ...
end

  def is_place_search?
    @options.location_name.present? && @options.original_distance < 90
  end


# make this method hit facebook, given a location_name, and find the facebook_places_id which IG accepts
# "venue" parsing will be different
def get_results_by_place(place_count=1)
  request = Typhoeus::Request.new(@endpoints.location_search(@options.latitude, @options.longitude), followlocation: true, timeout: @timeout).tap do |request|
    request.on_complete do |response|
      venues = Oj.load(response.body).fetch('response', {})['venues']

      if venues.try(:any?)
        venues.sort_by! { |venue| [ -venue['hereNow']['count'], -venue['stats']['usersCount'] ] }
        foursquare_venue_ids = venues.first(place_count).map { |venue| venue['id'] }

        foursquare_venue_ids.each do |foursquare_venue_id|
          search_with_foursquare_venue_id(foursquare_venue_id)
        end
      end
    end

    @hydra.queue(request)
  end
end

def get_results_by_place_options
  {
    query:     @options.location_name,
    radius:    @options.original_distance,
    latitude:  @options.latitude,
    longitude: @options.longitude
  }
end


# from endpoints.rb
def foursquare_venue_search(options={})
  if options[:query]
    "https://api.foursquare.com/v2/venues/search?client_id=#{CaptureSocialSearch::Settings.foursquare_client_id}&client_secret=#{CaptureSocialSearch::Settings.foursquare_client_secret}&intent=checkin&limit=5&ll=#{options[:latitude]}%2C#{options[:longitude]}&radius=#{options[:radius]}&query=#{URI.encode_www_form_component(options[:query])}&v=20140806&m=foursquare"
  else
    "https://api.foursquare.com/v2/venues/search?client_id=#{CaptureSocialSearch::Settings.foursquare_client_id}&client_secret=#{CaptureSocialSearch::Settings.foursquare_client_secret}&intent=checkin&limit=25&ll=#{options[:latitude]}%2C#{options[:longitude]}&radius=#{options[:radius]}&v=20140806&m=foursquare"
  end
end


def location_recent_media(options={})
  "#{BASE}/locations/#{options[:location_id]}/media/recent.json?count=#{MAX_COUNT}&max_id=#{options[:max_id]}&max_timestamp=#{options[:max_timestamp]}&min_timestamp=#{options[:min_timestamp]}&#{@auth_string}"
end


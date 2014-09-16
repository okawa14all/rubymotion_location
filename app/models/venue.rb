class Venue
  PROPERTIES = [:venue_id, :name, :address, :latitude, :longitude, :categories]
  PROPERTIES.each do |prop|
    attr_accessor prop
  end

  CLIENT_ID = 'CTMJCXM1YL1QI3FM1NE4K334DQ133ELXETFUUQDZPFHBY1RO'
  CLIENT_SECRET = '4IK2WDCTOG4ICN0A5FGQ3Y5PJJRJ15242YKRTUP51NLCANRU'
  VERSION_PARAM = 20140916
  LIMIT = 20

  def initialize(attributes = {})
    attributes.each do |key, value|
      self.send("#{key}=", value) if PROPERTIES.member?(key.to_sym)
    end
  end

  def self.search(params, &callback)
    params.merge!(
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      v: VERSION_PARAM,
      limit: LIMIT
    )

    AFMotion::SessionClient.shared.get('venues/search', params) do |result|
      if result.success?
        venues = []
        result.object['response']['venues'].each do |data|
          venue = Venue.new(
            venue_id: data['id'],
            name: data['name'],
            address: data['location']['formattedAddress'].join(' '),
            latitude: data['location']['lat'],
            longitude: data['location']['lng'],
            categories: data['categories'].map{ |ctg| ctg['name'] }.join(','),
          )
          venues << venue
        end
        callback.call(venues, nil)
      elsif result.failure?
        callback.call([], result.error)
      end
    end
  end

end

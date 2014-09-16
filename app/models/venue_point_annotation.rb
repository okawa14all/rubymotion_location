class VenuePointAnnotation
  attr_accessor :title, :subtitle, :venue

  def initialize(venue=nil)
    @venue = venue
    @coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
    @title = venue.name
    @subtitle = venue.categories
  end

  def coordinate
    @coordinate
  end

  def setCoordinate(coord)
    @coordinate = coord
  end
end

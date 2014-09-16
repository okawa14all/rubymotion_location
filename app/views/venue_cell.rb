class VenueCell < UITableViewCell

  def rmq_build
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator
    q = rmq(self.contentView)
    @name = q.build(self.textLabel, :cell_label).get
    @details = q.build(self.detailTextLabel, :cell_detail_label).get
  end

  def update(venue)
    @name.text = venue.name
    @details.text = "#{venue.categories}(#{venue.address})"
  end
end

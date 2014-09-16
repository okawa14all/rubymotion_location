class LocationController < UIViewController
  include MapKit

  PIN_ANNOTATION_ID = 'PinAnnotationIdentifier'
  DEFAULT_VENUE_CELL_ID = "DefaultVenueCell"
  SEARCHED_VENUE_CELL_ID = "SearchedVenueCell"

  def viewDidLoad
    super

    self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = LocationControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    @scrollView = rmq.append(UIScrollView, :scroll_view).get

    @searchBar = rmq(@scrollView).append(UISearchBar, :venue_search_bar).get.tap do |sb|
      sb.placeholder = 'あなたはどこにいますか？'
      sb.setShowsCancelButton(false, animated:false)
      sb.resignFirstResponder
      sb.delegate = self
    end

    @search_controller = UISearchDisplayController.alloc.initWithSearchBar(@searchBar, contentsController:self).tap do |sc|
      sc.delegate = self
      sc.searchResultsDataSource = self
      sc.searchResultsDelegate = self
    end


    @tableView = rmq(@scrollView).append(UITableView, :venue_table).get.tap do |tv|
      tv.delegate = self
      tv.dataSource = self
      tv.setSeparatorInset(UIEdgeInsetsZero)
    end

    puts BW::Location.enabled?
    puts BW::Location.authorized?

    BW::Location.get_once(purpose: 'hogehoge') do |result|
      if result.is_a?(CLLocation)
        @latitude = result.coordinate.latitude
        @longitude = result.coordinate.longitude

        puts @latitude
        puts @longitude

        map = rmq(@scrollView).append(MapView, :map).get
        map.delegate = self
        map.region = CoordinateRegion.new(MKCoordinateRegionMakeWithDistance(result.coordinate, 30, 30))
        map.shows_user_location = true

        Venue.search(ll: "#{@latitude},#{@longitude}") do |venues, error|
          if error
            App.alert(error.localizedDescription)
          else
            @venues = venues
            @venues.each do |venue|
              map.addAnnotation(VenuePointAnnotation.new(venue))
            end
            # TODO show table view
            @tableView.reloadData
          end
        end

      else
        p "ERROR: #{result[:error]}"
        # DISABLED=0
        # PERMISSION_DENIED=1
        # NETWORK_FAILURE=2
        # LOCATION_UNKNOWN=3
        App.alert("設定で位置情報サービスを有効にしてください")
      end
    end
  end

  def init_nav
    self.title = '場所'
    self.navigationItem.tap do |nav|
      nav.leftBarButtonItem = UIBarButtonItem.alloc.initWithTitle(
        'キャンセル',
        style: UIBarButtonItemStylePlain,
        target: self,
        action: :dismissView
      )
    end
  end

  def dismissView
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  # MKMapView delegate
  def mapView(mapView, viewForAnnotation:annotation)
    pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(PIN_ANNOTATION_ID) || begin
      pv = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier: PIN_ANNOTATION_ID)
      pv.canShowCallout = true
      rightButton = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
      pv.rightCalloutAccessoryView = rightButton
      pv
    end
    pinView
  end

  def mapView(mapView, annotationView:view, calloutAccessoryControlTapped:control)
    open_post_controller(view.annotation.venue)
  end

  # UITableView delegate
  #  for default contents of UITableView, and UISearchDisplayController's UISearchResultsTableView
  def tableView(table_view, numberOfRowsInSection: section)
    case
    when table_view.instance_of?(UITableView)
      if @venues
        @venues.length
      else
        0
      end
    when table_view.instance_of?(UISearchResultsTableView)
      if @user_searched_venues
        @user_searched_venues.length
      else
        0
      end
    end
  end

  def tableView(table_view, heightForRowAtIndexPath: index_path)
    rmq.stylesheet.venue_cell_height
  end

  def tableView(table_view, cellForRowAtIndexPath: index_path)
    case
    when table_view.instance_of?(UITableView)
      venue = @venues[index_path.row]
      identifier = DEFAULT_VENUE_CELL_ID
    when table_view.instance_of?(UISearchResultsTableView)
      venue = @user_searched_venues[index_path.row]
      identifier = SEARCHED_VENUE_CELL_ID
    end

    cell = table_view.dequeueReusableCellWithIdentifier(identifier) || begin
      rmq.create(
        VenueCell, :venue_cell,
        reuse_identifier: identifier,
        cell_style: UITableViewCellStyleSubtitle
      ).get
    end

    cell.update(venue)
    cell
  end

  def tableView(table_view, didSelectRowAtIndexPath: index_path)
    case
    when table_view.instance_of?(UITableView)
      venue = @venues[index_path.row]
    when table_view.instance_of?(UISearchResultsTableView)
      venue = @user_searched_venues[index_path.row]
    end
    open_post_controller(venue)
  end

  # UISearchBar delegate
  def searchBarShouldBeginEditing(searchBar)
    searchBar.showsScopeBar = true
    searchBar.sizeToFit
    searchBar.setShowsCancelButton(true, animated:true)
    true
  end

  def searchBarShouldEndEditing(searchBar)
    searchBar.showsScopeBar = false
    searchBar.sizeToFit
    searchBar.setShowsCancelButton(false, animated:true)
    true
  end

  def searchBarCancelButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end

  def searchBarSearchButtonClicked(searchBar)
    searchBar.resignFirstResponder
  end

  # SearchDisplayController delegate
  def searchDisplayController(controller, shouldReloadTableForSearchString:searchString)
    if searchString.present?
      Venue.search(ll: "#{@latitude},#{@longitude}", query: searchString) do |venues, error|
        if error
          App.alert(error.localizedDescription)
        else
          @user_searched_venues = venues
          puts @user_searched_venues.size
          controller.searchResultsTableView.reloadData
        end
      end
    end
    false
  end

  # open next view_controller
  def open_post_controller(venue)
    controller = PostController.new
    controller.venue = venue
    self.navigationController.pushViewController(controller, animated:true)
  end
end

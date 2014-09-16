class MainController < UIViewController

  def viewDidLoad
    super

    # Sets a top of 0 to be below the navigation control, it's best not to do this
    # self.edgesForExtendedLayout = UIRectEdgeNone

    rmq.stylesheet = MainStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    # Create your UIViews here
    # @hello_world_label = rmq.append(UILabel, :hello_world).get
    rmq.append(UIButton, :post_button).on(:touch) do |sender|
      open_location_controller
    end

  end

  def open_location_controller
    controller = LocationController.new
    nav_controller = UINavigationController.alloc.initWithRootViewController(controller)
    self.presentViewController(nav_controller, animated:true, completion:nil)
  end

  def init_nav
    self.title = 'Title Here'
  end

end

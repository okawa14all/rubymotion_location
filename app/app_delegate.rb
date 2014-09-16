class AppDelegate
  attr_reader :window

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    init_session_client

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    main_controller = MainController.new
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(main_controller)

    @window.makeKeyAndVisible
    true
  end

  def init_session_client
    AFMotion::SessionClient.build_shared('https://api.foursquare.com/v2/') do
      session_configuration :default
      header "Accept", "application/json"
      request_serializer :json
    end
    AFNetworkActivityIndicatorManager.sharedManager.enabled = true
  end
end

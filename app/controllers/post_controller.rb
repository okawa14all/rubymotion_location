class PostController < UIViewController
  attr_accessor :venue

  def viewDidLoad
    super

    rmq.stylesheet = PostControllerStylesheet
    init_nav
    rmq(self.view).apply_style :root_view

    # Create your views here
  end

  def init_nav
    self.title = self.venue.name
    self.navigationItem.tap do |nav|
      nav.rightBarButtonItem = UIBarButtonItem.alloc.initWithTitle(
        '投稿',
        style: UIBarButtonItemStylePlain,
        target: self,
        action: :dismissView
      )
    end
  end

  def dismissView
    self.dismissViewControllerAnimated(true, completion:nil)
  end
end

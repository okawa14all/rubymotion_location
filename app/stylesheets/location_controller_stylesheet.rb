class LocationControllerStylesheet < ApplicationStylesheet
  # Add your view stylesheets here. You can then override styles if needed, example:
  include VenueCellStylesheet

  def setup
    # Add stylesheet specific setup stuff here.
    # Add application specific setup stuff in application_stylesheet.rb
  end

  def root_view(st)
    st.background_color = color.white
  end

  def scroll_view(st)
    st.frame = { l: 0, t: 0, w: app_width, h: app_height }
  end

  def venue_search_bar(st)
    st.frame = { l: 0, t: 0, w: app_width, h: 44 }
  end

  def map(st)
    st.frame = { l: 0, t: 44, w: app_width, h: 200 }
  end

  def venue_table(st)
    st.frame = { l: 0, t: 244, w: app_width, h: app_height - 210 - 44 - 44 }
  end
end

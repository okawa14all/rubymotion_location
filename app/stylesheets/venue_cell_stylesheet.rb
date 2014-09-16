module VenueCellStylesheet

  def venue_cell_height
    70
  end

  def venue_cell(st)
    st.background_color = color.clear
    st.view.selectionStyle = UITableViewCellSelectionStyleNone
  end

  def cell_label(st)
    # st.color = color.white
  end

  def cell_detail_label(st)
    st.color = color.gray
  end

end

$ ->
  $("table tr").mouseover ->
    $(this).css({"background":"#f9ef9e"})
  $("table tr").mouseout ->
    $(this).css({"background":"#ffffff"})
  
  # $("#list2").jqGrid "setGridWidth", 1200

  # ie_position = ->
  #   $("#list2").jqGrid "setGridWidth", 1200
  #   w_height = $(window).height()
  #   isIE6 = !!window.ActiveXObject && !window.XMLHttpRequest
  #   if isIE6
  #     if w_height > 630
  #       $(".navbar-fixed-bottom").removeClass("position_one").addClass("position_two")
  #     else
  #       $(".navbar-fixed-bottom").removeClass("position_two").addClass("position_one")

  # jQuery.event.add window, "load", ie_position
  # jQuery.event.add window, "resize", ie_position
  # jQuery.event.add window, "scroll", ie_position
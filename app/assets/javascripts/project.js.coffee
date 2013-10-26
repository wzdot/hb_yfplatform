$ ->
  $("table tbody tr").mouseover ->
    $(this).css({"background":"#f9ef9e"})
  $("table tbody tr").mouseout ->
    $(this).css({"background":"#ffffff"})

  # 下拉菜单
  dropdown_flag = true
  $("a.dropdown-toggle").click ->
    if dropdown_flag
      $(".navbar-container div#dropdown-menu").show()
      dropdown_flag = false
    else 
      $(".navbar-container div#dropdown-menu").hide()
      dropdown_flag = true
      
  if $(".navbar-container div#dropdown-menu").length > 0
    $("body").click ->
      $(".navbar-container div#dropdown-menu").hide() 
      dropdown_flag = true
 
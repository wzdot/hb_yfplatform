$ ->
  document.ondragstart = (e)-> 
    return false
  if $("body").css("zoom")?
    $("body").css("zoom":1)

  #button hover css
  $("button").hover (->
    $(this).addClass "btn-hover"
  ), ->
    $(this).removeClass "btn-hover"

  $("#help-btn").click ->
    $("#help-layer").fadeIn(200)
    $("#help-popbox").fadeIn(400)
  $("#help-layer").click ->
    $("#help-layer").fadeOut(200)
    $("#help-popbox").fadeOut(200)
  $("#close-help-popbox").click ->
    $("#help-layer").fadeOut(200)
    $("#help-popbox").fadeOut(200)

  $("#add-irp-btn").uploadify
    buttonText: "装载红外图"
    auto: true
    multi: false
    width: 104
    height: 25
    successTimeout: 30
    buttonClass: "uploadify-btn"
    fileSizeLimit: '5MB'
    buttonImage : "/assets/icon-add.png"
    swf: "/assets/uploadify.swf"
    uploader: "special/import.json"
    fileTypeExts: '*.jpg'

  $("#add-irm-btn").uploadify
    buttonText: "装载可见光"
    auto: true
    multi: false
    width: 104
    height: 25
    successTimeout: 30
    buttonClass: "uploadify-btn"
    fileSizeLimit: '5MB'
    buttonImage : "/assets/icon-add.png"
    swf: "/assets/uploadify.swf"
    uploader: "special/import.json"
    fileTypeExts: '*.jpg'

  $("#add-bmp-btn").uploadify
    buttonText: "装载基准图"
    auto: true
    multi: false
    width: 104
    height: 25
    successTimeout: 30
    buttonClass: "uploadify-btn"
    fileSizeLimit: '5MB'
    buttonImage : "/assets/icon-add.png"
    swf: "/assets/uploadify.swf"
    uploader: "special/import.json"
    fileTypeExts: '*.jpg'

  $("#add-multi-btn").uploadify
    buttonText: "批量导入基准图"
    auto: true
    multi: false
    width: 125
    height: 25
    successTimeout: 30
    buttonClass: "uploadify-btn uploadify-multi-btn"
    fileSizeLimit: '5MB'
    buttonImage : "/assets/icon-multi.png"
    swf: "/assets/uploadify.swf"
    uploader: "special/import.json"
    fileTypeExts: '*.jpg'

  $(".uploadify-btn").css({"text-indent":10,"background-position":"10px 5px"})
  $(".uploadify-multi-btn").css({"text-indent":20,"background-position":"10px 5px"})
  $(".uploadify-btn").hover (->
    $(this).addClass "btn-hover"
  ), ->
    $(this).removeClass "btn-hover"
  # manipulate-canvas  
  mousedown_flag = false
  delete_one = undefined
  draw_path = undefined

  mousedown_x = undefined
  mousedown_y = undefined
  mouseup_x = undefined
  mouseup_y = undefined
  mousedown_cx = undefined
  mousedown_cy = undefined

  draw_point = undefined
  point_count = 0
  point = undefined
  point_text = undefined
  point_set = undefined
  point_group = []
  point_index = undefined
  point_index_count = 0
  point_name_count = 0

  draw_line = undefined
  line_count = 0
  line = undefined
  line_text = undefined
  line_set = undefined
  line_group = []
  line_index = undefined
  line_index_count = 0
  line_name_count = 0
  

  draw_circle = undefined
  circle_count = 0
  circle = undefined
  circle_text = undefined
  circle_set = undefined
  circle_group = []
  circle_index = undefined
  circle_index_count = 0
  circle_name_count = 0
  

  draw_rect = undefined
  rect_count = 0
  rect = undefined
  rect_text = undefined
  rect_set = undefined 
  rect_group = []
  rect_index = undefined
  rect_index_count = 0
  rect_name_count = 0

  point_rename = (e)->
    if e.attr("text")?
      e.attr({"text":"point#{point_name_count}"})
      point_name_count++ 
    if e.index?
      e.index = point_index_count
      point_index_count++
  
  line_rename = (e)->
    if e.attr("text")?
      e.attr({"text":"line#{line_name_count}"})
      line_name_count++ 
    if e.index?
      e.index = line_index_count
      line_index_count++

  circle_rename = (e)->
    if e.attr("text")?
      e.attr({"text":"circle#{circle_name_count}"})
      circle_name_count++ 
    if e.index?
      e.index = circle_index_count
      circle_index_count++

  rect_rename = (e)->
    if e.attr("text")?
      e.attr({"text":"rect#{rect_name_count}"})
      rect_name_count++ 
    if e.index?
      e.index = rect_index_count
      rect_index_count++
  # draw point
  $("#draw-point").click ->
    draw_point = true
    draw_line = false
    draw_rect = false
    draw_circle = false
    delete_one = false
    delete_all = false
  # draw line
  $("#draw-line").click ->
    draw_point = false
    draw_line = true
    draw_rect = false
    draw_circle = false
    delete_one = false
    delete_all = false 
  # draw rect
  $("#draw-rect").click ->
    draw_point = false
    draw_line = false
    draw_rect = true
    draw_circle = false
    delete_one = false
    delete_all = false
  # draw circle
  $("#draw-circle").click ->
    draw_point = false
    draw_line = false
    draw_rect = false
    draw_circle = true
    delete_one = false
    delete_all = false  
  # delete one
  $("#delete-one").click ->
    draw_point = false
    draw_line = false
    draw_rect = false
    draw_circle = false
    delete_one = true
    delete_all = false 
  # delete all
  $("#delete-all").click ->
    paper.clear()
    irm = paper.image("assets/irm.jpg", 0, 0, 640, 480).hide()
    irp = paper.image("assets/irp.jpg", 0, 0, 640, 480)
    bmp = paper.image("assets/outline.png", 0, 0, 640, 480).attr("opacity", 0.5)
    mousedown_flag = false
    delete_one = undefined
    draw_path = undefined
    
    mousedown_x = undefined
    mousedown_y = undefined
    mouseup_x = undefined
    mouseup_y = undefined

    draw_point = undefined
    point_count = 0
    point = undefined
    point_text = undefined
    point_set = undefined
    point_group = []
    point_index = undefined
    point_index_count = 0
    point_name_count = 0

    draw_line = undefined
    line_count = 0
    line = undefined
    line_text = undefined
    line_set = undefined
    line_group = []
    line_index = undefined
    line_index_count = 0
    line_name_count = 0
    

    draw_circle = undefined
    circle_count = 0
    circle = undefined
    circle_text = undefined
    circle_set = undefined
    circle_group = []
    circle_index = undefined
    circle_index_count = 0
    circle_name_count = 0
    

    draw_rect = undefined
    rect_count = 0
    rect = undefined
    rect_text = undefined
    rect_set = undefined 
    rect_group = []
    rect_index = undefined
    rect_index_count = 0
    rect_name_count = 0
    

  paper = Raphael("manipulate-canvas",0,0, 640, 480)
  paper.fixNS()
  paper.draggable.enable()
  $("svg").prependTo("#manipulate-canvas").css({"height":480,"width":640})
  irm = paper.image("assets/irm.jpg", 0, 0, 640, 480).hide()
  irp = paper.image("assets/irp.jpg", 0, 0, 640, 480)
  bmp = paper.image("assets/outline.png", 0, 0, 640, 480).attr({"opacity": 0.5})



  $("svg").mousedown (e) ->
    mousedown_flag = true
    mousedown_x = e.pageX - $(this).offset().left
    mousedown_y = e.pageY - $(this).offset().top
    # drawing point
    if draw_point
      point_text = paper.text(mousedown_x-5, mousedown_y-15, "point#{point_count}").attr(
        "fill": "#00ffff"
        "font-size": "15px"
        "font-weight": "bold"
        "cursor": "move"
      )
      point = paper.circle(mousedown_x, mousedown_y, 4).attr(
        "fill": "#f00"
        "fill-opacity": 0.1
        "stroke": "#00ffff"
        "stroke-width": 2
        "cursor": "move"
      )
      point_set = paper.set().draggable.enable()
      point_set.push(point,point_text)
      point.index = point_count
      point_group.push(point_set)
      point_count++
      draw_point = false

    # delete point 
    if point_count > 0
      point.mousedown ->
        if delete_one
          point_index_count = 0
          point_name_count = 0 
          point_index = @index
          point_group[point_index].remove()
          point_group.splice(point_index,1)
          for item in point_group
            item.forEach(point_rename,this)
          point_count--
          delete_one = false
    
    # drawing line
    if draw_line 
      line_text = paper.text(mousedown_x+15,mousedown_y- 10,"line#{line_count}").attr(
        "fill": "#00ffff"
        "font-size": "15px"
        "font-weight": "bold"
        "cursor": "move"
      )
      line = paper.path("M#{mousedown_x} #{mousedown_y}L#{mousedown_x} #{mousedown_y}").attr(
        "stroke": "#00ffff"
        "stroke-width": 2
        "cursor": "move"
      ).draggable.enable()

    # drawing rect
    if draw_rect
      rect_text = paper.text(mousedown_x+15,mousedown_y- 10,"rect#{rect_count}").attr(
        "fill": "#00ffff"
        "font-size": "15px"
        "font-weight": "bold"
        "cursor": "move"
      )
      rect = paper.rect(mousedown_x, mousedown_y,1, 1).attr(
        "fill": "#00ffff"
        "fill-opacity": 0.1
        "stroke": "#00ffff"
        "stroke-width": 2
        "cursor": "move"
      ).draggable.enable()
    # drawing circle
    if draw_circle
      circle_text = paper.text(mousedown_x,mousedown_y,"circle#{circle_count}").attr(
        "fill": "#00ffff"
        "font-size": "15px"
        "font-weight": "bold"
        "cursor": "move"
      )
      circle = paper.circle(mousedown_x, mousedown_y, 5).attr(
        "fill": "#00ffff"
        "fill-opacity": 0.1
        "stroke": "#00ffff"
        "stroke-width": 2
        cursor: "move"
      ).draggable.enable()

    $("svg").bind 'mousemove', (e) ->
      mousemove_x = e.pageX - $(this).offset().left
      mousemove_y = e.pageY - $(this).offset().top
      mousepath_x = Math.abs(mousemove_x - mousedown_x)
      mousepath_y = Math.abs(mousemove_y - mousedown_y)
      mousepath_x = mousepath_x * mousepath_x
      mousepath_y = mousepath_y * mousepath_y
      mousepath = mousepath_x + mousepath_y
      mousepath = Math.sqrt(mousepath)
      


      if draw_line 
        change_path = "M#{mousedown_x} #{mousedown_y}L#{mousemove_x} #{mousemove_y}"
        line.attr("path", change_path) 
      if draw_rect
        change_width = Math.sqrt(mousepath_x)
        change_height = Math.sqrt(mousepath_y)
        rect.attr("width", change_width)
        rect.attr("height", change_height)
      if draw_circle
        circle.attr("r", mousepath)
    

  $("svg").mouseup (e) ->
    $("svg").unbind('mousemove')
    if draw_line 
      line_set = paper.set().draggable.enable()
      line_set.push(line,line_text)
      line.index = line_count
      line_group.push(line_set)
      line_count++
      draw_line = false

    if draw_rect
      rect_set = paper.set().draggable.enable()
      rect_set.push(rect,rect_text)
      rect.index = rect_count
      rect_group.push(rect_set)
      rect_count++
      draw_rect = false

    # drawing circle
    if draw_circle    
      circle_set = paper.set().draggable.enable()
      circle_set.push(circle,circle_text)
      circle.index = circle_count
      circle_group.push(circle_set)
      circle_count++
      draw_circle = false

    # delete line
    if line_count > 0
      line.mouseup ->
        if delete_one
          line_index_count = 0
          line_name_count = 0 
          line_index = @index
          line_group[line_index].remove()
          line_group.splice(line_index,1)
          for item in line_group
            item.forEach(line_rename,this)
          line_count--
          delete_one = false

    # delete rect
    if rect_count > 0
      rect.mouseup ->
        if delete_one
          rect_index_count = 0
          rect_name_count = 0 
          rect_index = @index
          rect_group[rect_index].remove()
          rect_group.splice(rect_index,1)
          for item in rect_group
            item.forEach(rect_rename,this)
          rect_count--
          delete_one = false

    # delete circle
    if circle_count > 0
      circle.mouseup ->
        if delete_one
          circle_index_count = 0
          circle_name_count = 0 
          circle_index = @index
          circle_group[circle_index].remove()
          circle_group.splice(circle_index,1)
          for item in circle_group
            item.forEach(circle_rename,this)
          circle_count--
          delete_one = false

  show_irm = true
  show_irp = false
  show_bmp = false

  $("#show-irp").click ->
    if show_irp
      irp.show()
      irm.hide()
      $(this).children("span").text("隐藏红外图")
      $("#show-irm").children("span").text("显示可见光")
      show_irp = false
      show_irm = true
      $("#manipulate-btn button").attr({"disabled":false}).find("img").css({"opacity":1})
    else
      irp.hide()
      $(this).children("span").text("显示红外图")
      show_irp = true
      $("#manipulate-btn button").attr({"disabled":true}).find("img").css({"opacity":0.5})

  $("#show-irm").click ->
    if show_irm
      irp.hide()
      irm.show()
      $(this).children("span").text("隐藏可见光")
      $("#show-irp").children("span").text("显示红外图")
      show_irp = true
      show_irm = false
      $("#manipulate-btn button").attr({"disabled":true}).find("img").css({"opacity":0.5})
    else
      irm.hide()
      $(this).children("span").text("显示可见光")
      show_irm = true

  $("#show-bmp").click ->
    if show_bmp 
      bmp.show()
      $(this).children("span").text("隐藏基准图")
      show_bmp = false
    else
      bmp.hide()
      $(this).children("span").text("显示基准图")
      show_bmp = true
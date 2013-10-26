url = window.location.href
paraString = url.slice(url.indexOf("?")+1,url.length)
flag = false
counter = 1
data = [
  image: "assets/photo3.jpg"
  thumb: "assets/photo3.jpg"
  big: "assets/photo3.jpg"
  description: "YF红外检测一体化分析平台 —— 红外图片展示"  
]
totalImages = data.length
end = false
page = 1
loadnum = 50
Galleria.run "#galleria",
  dataSource: data
  responsive: true
  height: 0.62
  debug: false
  _toggleInfo: false
  easing: "galleriaIn"
  transition: "slide"
  imageMargin: 50

Galleria.ready (options) ->
  @addElement "btn-control"
  @appendChild "container", "btn-control"
  @$('btn-control').html "<div id='autoplay'>" + "<img src='assets/play.png' title='自动播放' class='play'/>" + "<img src='assets/pause.png' title='暂停' class='pause'/>" + "</div>" + "<select id='playtime'>" + "<option>播放时间</option>" + "<option>1秒</option>" + "<option>2秒</option>" + "<option>3秒</option>" + "<option>4秒</option>" + "<option>5秒</option>" + "<option>6秒</option>" + "<option>7秒</option>" + "<option>8秒</option>" + "</select>" + "<div id='fullscreen'>" + "<img src='assets/view-fullscreen.png' title='全屏' class='view-fullscreen'/>" + "<img src='assets/view-restore.png' title='恢复' class='view-restore'/>" + "</div>" + "<div id='div_scale'><img src='assets/scale.png' title='图片原始尺寸' class='img_scale'/></div>" +  "<div id = 'show_num'><span>第</span><input id='btn_show' value=''/><span>张</span><div class='btn'>确定</div></div>"
  @bind "loadfinish", (e) ->
    if e.index is totalImages - 1 and end is false
      $.ajax
        type: "GET"
        url: "/irp_slider.json?page_no=" + page + "&page_size=" + loadnum + "&" + paraString
        dataType: "json"
        success: (result) ->
          adddata = result
          i = 0

          while i < adddata.length
            Galleria.get(0).push adddata[i]
            i++
          if adddata.length < loadnum
            end = true
          else
            end = false
          return

        error: (x) ->
          alert x.readyState + " " + x.status + " "
          return   
    
      totalImages = totalImages + loadnum
      page = page + 1
      return
      
  #play and pause function
  $('#autoplay').click ->
    playtime = $('#playtime').val()
    if counter%2 is 1
      flag = true
      $('.play').hide()
      $('.pause').show()
      if playtime is '1秒' and flag is true
        $('#galleria').data('galleria').play(1000)
      else if playtime is '2秒' and flag is true
        $('#galleria').data('galleria').play(2000)
      else if playtime is '3秒' and flag is true
        $('#galleria').data('galleria').play(3000)
      else if playtime is '4秒' and flag is true
        $('#galleria').data('galleria').play(4000)
      else if playtime is '5秒' and flag is true
        $('#galleria').data('galleria').play(5000)
      else if playtime is '6秒' and flag is true
        $('#galleria').data('galleria').play(6000)
      else if playtime is '7秒' and flag is true
        $('#galleria').data('galleria').play(7000)
      else if playtime is '8秒' and flag is true
        $('#galleria').data('galleria').play(8000)
      else if flag is true
        $('#galleria').data('galleria').play(4000)
    else if counter%2 is 0
      flag = false
      $('.pause').hide()
      $('.play').show()
      $('#galleria').data('galleria').pause()
    counter++ 
    return

  #defined play time
  $('#playtime').change ->
    playtime = $(this).val()
    if playtime is '1秒' and flag is true
      $('#galleria').data('galleria').play(1000)
    else if playtime is '2秒' and flag is true
      $('#galleria').data('galleria').play(2000)
    else if playtime is '3秒' and flag is true
      $('#galleria').data('galleria').play(3000)
    else if playtime is '4秒' and flag is true
      $('#galleria').data('galleria').play(4000)    
    else if playtime is '5秒' and flag is true
      $('#galleria').data('galleria').play(5000)  
    else if playtime is '6秒' and flag is true
      $('#galleria').data('galleria').play(6000)
    else if playtime is '7秒' and flag is true
      $('#galleria').data('galleria').play(7000)
    else if playtime is '8秒' and flag is true
      $('#galleria').data('galleria').play(8000)
    else if flag is true
      $('#galleria').data('galleria').play(4000)
    

  #1:1 function btn
  $('#div_scale').click ->
    Galleria.get(0).pause()
    $('.pause').hide()
    $('.play').show()
    flag = false
    if counter%2 is 0
      counter++
    else if counter%2 is 1
      counter = counter
    Galleria.get(0).openLightbox()
    return  
  
  $("#show_num > .btn").click (e) ->
    e.preventDefault
    dataLength = Galleria.get(0).getDataLength()
    pic_index = $("#btn_show").val()
    if pic_index.length < 1
      return
    else  
      pic_index = $.trim(pic_index)
      pic_index = parseInt(pic_index) - 1
      msg = '请正确填写跳转图片张数'
      regtex = /^\d*/     
      if regtex.test pic_index 
        if pic_index > 0 && pic_index < dataLength
          Galleria.get(0).show(pic_index) 
        else
          alert msg
      else
        alert msg
      # if pic_index < 0 
      #   alert msg
      # else if pic_index > dataLength
      #   alert msg 
      # else if not regtex.test pic_index 
      #   alert msg
      # else
      #   Galleria.get(0).show(pic_index) 

  #fullscreen function
  $('#fullscreen').click ->
    $('#galleria').data('galleria').toggleFullscreen()
    return
  
  @bind "fullscreen_enter", (e) ->
    $('.view-fullscreen').hide()
    $('.view-restore').show()
    $('#show_num').css({"visibility":"hidden"})
    return

  @bind "fullscreen_exit", (e) ->
    $('.view-fullscreen').show()
    $('.view-restore').hide()
    $('#show_num').css({"visibility":"visible"})
    return
  
  #left-right btn and thunbnails click funtion
  @$('image-nav-right').click ->
    $('.pause').hide()
    $('.play').show()
    flag = false
    if counter%2 is 0
      counter++
    else if counter%2 is 1
      counter = counter
    return
  
  @$('image-nav-left').click ->
    $('.pause').hide()
    $('.play').show()
    flag = false
    if counter%2 is 0
      counter++
    else if counter%2 is 1
      counter =  counter
    return
  
  @$('thumbnails').click ->
    $('.pause').hide()
    $('.play').show()
    flag = false
    if counter%2 is 0
      counter++
    else if counter%2 is 1
      counter = counter
    return    
  return
 
$("body").keydown (e) ->
  if $(".view-restore").is(":hidden") and not $(".galleria-lightbox-box").is(":visible")
    if e.keyCode is 37
      Galleria.get(0).pause()
      $(".pause").hide()
      $(".play").show()
      flag = false
      if counter % 2 is 0
        counter++
      else counter = counter  if counter % 2 is 1
      Galleria.get(0).prev()
    else if e.keyCode is 39
      Galleria.get(0).pause()
      $(".pause").hide()
      $(".play").show()
      flag = false
      if counter % 2 is 0
        counter++
      else counter = counter  if counter % 2 is 1
      Galleria.get(0).next()

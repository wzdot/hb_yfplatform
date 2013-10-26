# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->

  $(".warn_message").css({"color":"#499996"})

  $("#user_email").focus ->
    $(".warn_message:eq(0)").css({"color":"#ffffff"})
  $("#user_email").blur ->
    $(".warn_message:eq(0)").css({"color":"#499996"})

  $("#user_password").focus ->
    $(".warn_message:eq(1)").css({"color":"#ffffff"})
  $("#user_password").blur ->  
    $(".warn_message:eq(1)").css({"color":"#499996"})
  

  $("#user_smscode").focus ->
    $(".warn_message:eq(2)").css({"color":"#ffffff"})
  $("#user_smscode").blur ->
    $(".warn_message:eq(2)").css({"color":"#499996"})

  $("#user_captcha").focus ->
    $(".warn_message:eq(3)").css({"color":"#ffffff"})
  $("#user_captcha").blur ->
    $(".warn_message:eq(3)").css({"color":"#499996"})

  refresh_captcha = ->
    $('#captcha').val('')
    timestamp = Math.round new Date().getTime() / 1000
    $('img#captcha').attr('src', "/captcha?action=captcha&i=#{timestamp}")

	$.ajax
		url: "/users/page_show_extra"
		type: 'GET'
		dataType: 'json'
		success: (data) ->
      # console.log use_captcha
      if data.use_captcha
        refresh_captcha()
        $('form p.captcha_box').show()
      else
        $('form p.captcha_box').hide()
      if data.use_sms_code
        $('form p.smscode_box').show()
      else
        $('form p.smscode_box').hide()
      if not data.use_captcha || data.use_sms_code
        $("#login_checkbox").css({"visibility":"visible"})
        $(".login_checkbox").css({"visibility":"visible"})
      else
        $("#login_checkbox").css({"visibility":"hidden"})
        $(".login_checkbox").css({"visibility":"hidden"})
    error: (data) ->
      alert '数据错误'

	

	$('img#captcha').click ->
  	refresh_captcha()

  $('input[type=button]#btn_ask_sms').click (e)->
    email = $('#user_email').val()
    # email = $.trim(email)
    instance = $(this)
    
    # if email is ''
    #   $(".warn_message")[0].style.color = "#ffe45c"
    #   $("#user_email").focus()
    if email isnt ''
      $.ajax
        url: "/users/sms_code.json?email=#{email}"
        type: 'GET'
        success: (data) ->
          if data.success is 0
            alert data.desc
            count = 60          
            instance.attr "disabled", true
            text = "重新获取认证码"
            handler = setInterval (->
              count--
              instance.val "(#{count} 秒) #{text}"
              if count == 0
                instance.attr "disabled", false
                instance.val text
                clearInterval handler
            ), 1000
          else if data.success is -1
            $(".warn_message")[0].style.color = '#ffe45c'
            $(".warn_message:eq(0)").text(data.desc)
            $("#user_email").focus()
          else if data.success is 99
            $(".warn_message")[2].style.color = '#ffe45c'
            $(".warn_message:eq(2)").text(data.desc)
            $("#user_smscode").focus()
          else if data.success is 1
            $(".warn_message")[2].style.color = '#ffe45c'
            $(".warn_message:eq(2)").text(data.desc)
            $("#user_smscode").focus()
    else 
      $("#user_email").focus()

              


  $('form input#sign_in').click (e)->
    email = $('#user_email').val()
    # email = $.trim(email)
    password = $('#user_password').val()
    # password = $.trim(password)
    if $('#login_checkbox').length > 0
      remember_me = $('#login_checkbox').attr('checked') == 'checked' ? 1 : 0
    else
      smscode = $('#user_smscode').val()
      # smscode = $.trim(smscode)
    if $("#captcha_box").length > 0
      captcha = $('#user_captcha').val()
      # captcha = $.trim(captcha)
    else 
      captcha = true 
    if email is ''
      $(".warn_message")[0].style.color = '#ffe45c'
      $("#user_email").focus()
    else if password is ''
      $(".warn_message")[1].style.color = '#ffe45c'
      $("#user_password").focus()
    else if smscode is ''
      $(".warn_message")[2].style.color = '#ffe45c'
      $("#user_smscode").focus()
    else if captcha is ''
      $(".warn_message")[3].style.color = '#ffe45c'
      $("#user_captcha").focus()
    else
      $.ajax
        url: "/users/sign_in"
        type: 'POST'
        dataType: 'script'
        data: $("form").serialize()
        # success: (data) ->
        #   alert data
        # error: (XMLHttpRequest, textStatus, errorThrown) ->
        #   alert textStatus
        #   status = data.success
        #   if status is true
        #     location.href = data.desc
        #     alert data.desc
        #   else
        #     # refresh_captcha()
        #     if data.use_captcha
        #       $('form p.captcha_box').css('display', 'block')
        #     if data.use_sms_code
        #       $('form p.smscode_box').css('display', 'block')

        
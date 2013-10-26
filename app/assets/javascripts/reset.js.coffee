$ ->

  $("#user_password").focus ->
    $("span.position_one").show()
  $("#user_password").blur ->
    $("span.position_one").hide()

  $("#user_password_confirmation").focus ->
    $("span.position_two").show()
  $("#user_password_confirmation").blur ->
    $("span.position_two").hide()

  if $("#user_password_sms_code").length > 0
    $("#user_password_sms_code").focus ->
      $("span.position_three").show()
    $("#user_password_sms_code").blur ->
      $("span.position_three").hide()

  $("#user_email").focus ->
    $(".w_message").show()
  $("#user_email").blur ->
    $(".w_message").hide()

  $(".actions > input.btn").click (e) ->
    e.preventDefault()
    if $("#user_email").length > 0
      user_email = $("#user_email").val()
      # user_email = $.trim(user_email)
      email_regex = /^(?:\w+\.?)*\w+@(?:\w+\.?)*\w+$/
      if user_email is ''
        $("#user_email").focus()
        $(".w_message")[0].style.color = "#ff0000"
        $(".w_message").text("电子邮件不能为空") 
      else if email_regex.test user_email
        $.ajax
          url: "/users/password"
          type: 'POST'
          dataType: 'script'
          data: $("form").serialize()
      else 
        $("#user_email").focus()
        $(".w_message")[0].style.color = "#ff0000"
        $(".w_message").text("请正确填写电子邮件") 

    else
      newpassword = $("#user_password").val()
      # newpassword = $.trim(newpassword)
      newpassword_r = $("#user_password_confirmation").val()
      # newpassword_r = $.trim(newpassword_r)
      if $("#user_password_sms_code").length > 0
        user_password_sms_code = $("#user_password_sms_code").val()
      # user_password_sms_code = $.trim(user_password_sms_code)
      password_regex = /^\w{6,}/
      sms_regex = /^\d{6}/
      if password_regex.test newpassword
        if newpassword is newpassword_r
          if $("#user_password_sms_code").length > 0 && !sms_regex.test user_password_sms_code
            $("#user_password_sms_code").focus()
            $(".warn_message:eq(2)").text("认证码错误")
            $(".warn_message")[2].style.color = '#ff0000'  
          else
            # $("form:eq(0)").submit()
            $.ajax
              url: "/users/password"
              type: 'PUT'
              dataType: 'script'
              data: $("form").serialize() 
            
            
        else
          $(".warn_message:eq(1)").text("两次密码不匹配")
          $("#user_password_confirmation").focus()        
          $(".warn_message")[1].style.color = '#ff0000' 

      else
        $("#user_password").focus()
        $(".warn_message")[0].style.color = '#ff0000'  	
        
<% if request.env['warden'].unauthenticated? %>
msg = "<%= request.env['warden'].message %>"
if msg is 'unauthorized'
  $(".warn_message:eq(0)").text("用户名或密码错误")
  $(".warn_message")[0].style.color = "#ffe45c"
  $("#user_email").focus()
else if msg is 'sms_code_expired' 
  $(".warn_message:eq(2)").text("认证码过期")
  $(".warn_message")[2].style.color = "#ffe45c"
  $("#user_smscode").focus() 
else if msg is 'sms_code_unmatched'  
  $(".warn_message:eq(2)").text("认证码不匹配")
  $(".warn_message")[2].style.color = "#ffe45c"
  $("#user_smscode").focus()  
else if msg is 'captcha_unmatched'  
  $(".warn_message:eq(3)").text("验证码错误")
  $(".warn_message")[3].style.color = "#ffe45c"
  $("#user_captcha").focus() 
<% if User.use_sms_code? %>
$('form p.smscode_box').css('display', 'block')
<% end %>
<% if User.login_with_captcha? && (session[:login_fail_count] ||= 0) >= User.login_fail_count %>
timestamp = Math.round new Date().getTime() / 1000
$('img#captcha').attr('src', "/captcha?action=captcha&i=#{timestamp}")
$('form p.captcha_box').css('display', 'block')
<% end %>
<% else %>
<% if session[:return_to] %>
location.href="/oauth/authorize?<%= session[:return_to] %>"
<% else %>
<% flash[:notice] = I18n.t 'devise.sessions.signed_in' %>
location.href='/'
<% end %>
<% end %>
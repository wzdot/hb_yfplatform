<% if @resource.errors.empty? %>
location.href = '/'
<% else %>
<% @resource.errors.each do |key, msg| %>
<% if key == :reset_password_token %>
alert '<%= msg %>'
location.href = '<%= new_user_password_path %>'
return
<% end %>
<% if key == :password_sms_code %>
$("#user_password_sms_code").focus()
$(".warn_message")[2].style.color = '#ff0000'
$(".warn_message:eq(2)").text('<%= msg %>')
<% end %>
<% end %>
<% end %>
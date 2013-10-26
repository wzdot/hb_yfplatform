<% if @resource.errors.blank? %>
location.href = '/users/sign_in'
<% else %>
<% @resource.errors.each do |key, msg| %>
<% if key == :email %>
$("#user_email").focus()
$(".w_message").text('<%= msg %>' ) 
$(".w_message")[0].style.color = '#ff0000'
return
<% end %>
<% end %>
<% end %>

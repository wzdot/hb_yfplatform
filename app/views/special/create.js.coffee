<% if @status == 0 %>
alert '数据录入成功！'
# $("#submit_btn").attr "disabled" : true
# $("#irimage_list")[0].src = "/assets/display-picture.png"
# $("#station_level select:gt(0)").find("option:gt(0)").remove()
# $("#station_level select:eq(2)").find("option:eq(0)").text("- 变电站\\线路电压等级 -")
# $("#station_level select:eq(3)").find("option:eq(0)").text("- 变电站\\线路 -")
# $("#station_level select:eq(4)").find("option:eq(0)").text("- 间隔单元\\杆塔号电压等级 -")
# $("#station_level select:eq(5)").find("option:eq(0)").text("- 间隔单元\\杆塔号 -")
# $("#station_level select:eq(6)").find("option:eq(0)").text("- 设备\\部件类型 -")
# $("#station_level select:eq(7)").find("option:eq(0)").text("- 设备名称\\方向 -")
# $('form')[0].reset()
# $("input[type='text']").attr "disabled" : true
# $("input[type='text']").css "background" : "#eee"
# $(".shape_select").attr "disabled" : true
# $(".index_select").attr "disabled" : true
# $("#dispel_way").attr "disabled" : true
# $("#defect_property").attr "disabled" : true
# $("#excute_situation").attr "disabled" : true
# $("li.temperature:gt(0)").remove()
# $("li.temperature").find(".add_img").hide()
# $("li.temperature").find(".delete_img").hide()
# $("span.warn_message").css("color":"#333").hide()
# $("input[type='text']").css({"border-color":"#aaa"})
# $("#detect_date").siblings("span.detect_date_span").css({"color":"#333"}).text("加 * 必填").show()
# $("#detect_time").siblings("span.detect_time_span").css({"color":"#333"}).text("格式 hh:mm:ss").show()


$("#irimage_list")[0].src = "/assets/display-picture.png"
$("#station_level select:eq(0)").find("option:eq(0)").attr({"selected":true})
$("#station_level select:gt(0)").find("option:gt(0)").remove()
$("#station_level select:eq(2)").find("option:eq(0)").text("- 变电站\\线路电压等级 -")
$("#station_level select:eq(3)").find("option:eq(0)").text("- 变电站\\线路 -")
$("#station_level select:eq(4)").find("option:eq(0)").text("- 间隔单元\\杆塔号电压等级 -")
$("#station_level select:eq(5)").find("option:eq(0)").text("- 间隔单元\\杆塔号 -")
$("#station_level select:eq(6)").find("option:eq(0)").text("- 设备\\部件类型 -")
$("#station_level select:eq(8)").find("option:eq(0)").text("- 设备现场名称 -")
$('form')[0].reset()
$("input[type='text']").val("")
$(".step_two select").find("option:eq(0)").attr({"selected":true})
$("input[type='text']").attr "disabled" : true
$("input[type='text']").css "background" : "#eee"
$(".shape_select").attr "disabled" : true
$(".index_select").attr "disabled" : true
$("#dispel_way").attr "disabled" : true
$("#defect_property").attr "disabled" : true
$("#excute_situation").attr "disabled" : true
$("li.temperature:gt(0)").remove()
$("li.temperature").find(".add_img").hide()
$("li.temperature").find(".delete_img").hide()
$("span.warn_message").css("color":"#333").hide()
$("input[type='text']").css({"border-color":"#aaa"})
$("#detect_date").siblings("span.detect_date_span").css({"color":"#333"}).text("加 * 必填").show()
$("#detect_time").siblings("span.detect_time_span").css({"color":"#333"}).text("格式 hh:mm:ss").show()


<% elsif @status == 1 %>
alert '请不要录入重复的数据！'
<% else %>
alert '数据录入失败！'
<% end %>
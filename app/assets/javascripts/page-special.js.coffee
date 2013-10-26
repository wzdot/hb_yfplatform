# 图片本地预览功能
$("#irimage").uploadify
  buttonText: "上传红外图片"
  auto: true
  multi: false
  width: 100
  height: 25
  successTimeout: 30
  buttonClass: "uploadify_btn"
  fileSizeLimit: '5MB'
  swf: "/assets/uploadify.swf"
  uploader: "special/import.json"
  fileTypeExts: '*.jpg'
  onUploadStart: (file)->
    $("#irimage_load").show()
  onUploadSuccess: (file, result, response) ->
    json = $.parseJSON(result)
    filename = json.filename
    tempfile = json.tempfile
    if $("#oauth_irimage .file_detail").length > 0 
      $("#oauth_irimage .file_detail").remove()  
    $("#irimage_load").hide()
    $("img#irimage_list")[0].src = "system/uploads/data/tmp/#{tempfile}"
    input_str = "<input class='file_detail' type='text' value='#{filename}' name='ir_file'/><input class='file_detail' type='text' value='#{tempfile}' name='ir_temp'/>"
    $('img#irimage_list').css({"border-color":"#ccc"})
    $(input_str).appendTo("#oauth_irimage")

# $("#viimage").uploadify
#   buttonText: "上传可见光图片"
#   auto: true
#   multi: false
#   width: 100
#   height: 25
#   successTimeout: 30
#   buttonClass: "uploadify_btn"
#   fileSizeLimit: '5MB'
#   swf: "/assets/uploadify.swf"
#   uploader: "special/import.json"
#   fileTypeExts: '*.jpg'
#   onUploadStart: (file)->
#     $("#viimage_load").show()
#   onUploadSuccess: (file, result, response) ->
#     json = $.parseJSON(result)
#     filename = json.filename
#     tempfile = json.tempfile
#     if $("#oauth_viimage .file_detail").length > 0 
#       $("#oauth_viimage .file_detail").remove() 
#     $("#viimage_load").hide() 
#     $("img#viimage_list")[0].src = "system/uploads/data/tmp/#{tempfile}"
#     input_str = "<input class='file_detail' type='text' value='#{filename}' name='vi_file'/><input class='file_detail' type='text' value='#{tempfile}' name='vi_temp'/>"
#     $(input_str).appendTo("#oauth_viimage")

# ——————————————————————  单位选择至部位角度选择  联动下拉列表选择  ————————————————————————
# 禁用第二步填写的表单控件
disable_controls = ->
  $("#submit_btn").attr "disabled" : true
  $("input[type='text']").attr "disabled" : true
  $("input[type='text']").css "background" : "#eee"
  $(".shape_select").attr "disabled" : true
  $(".index_select").attr "disabled" : true
  $("#dispel_way").attr "disabled" : true
  $("#defect_property").attr "disabled" : true
  $("#excute_situation").attr "disabled" : true 
  $("li.temperature").find(".add_img").hide()
  $("li.temperature").find(".delete_img").hide()
  $("#station_level input[type='text']").attr "disabled" : false
  $("#station_level input[type='text']").css "background" : "#fff"

# 取消输入
$("#station_level img.cancel").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  if $div.siblings("span").length > 0
    $div.siblings("span").hide()
  $input.val("")
  $div.hide()
  $select.show()
  $select[0].selectedIndex = 0


# 单位选择
$("#region_company").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  $("#station_level select:gt(0)").find("option:gt(0)").remove()
  $("#station_level li div").hide().find("input").val("")
  $("#station_level select:gt(0)").show()
  if select_index isnt 0
    $.ajax
      type: "GET"
      url: "/special/lines/#{select_val}"
      dataType: "json"
      success: (data) ->
        if data.length > 0
          for item in data
            option_str = "<option value = #{item.id}>#{item.name}</option>" 
            $(option_str).appendTo("#line_id")

# 变\输\配电选择
$("#line_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  select_text = $(this).find("option:eq(#{select_index})").text().slice(0,2)
  $("#station_level select:gt(1)").find("option:gt(0)").remove()
  $("#station_level li div").hide().find("input").val("")
  $("#station_level select:gt(1)").show()
  if select_text is "变电"
    $("#station_level select:eq(2)").find("option:eq(0)").text("- 变电站电压等级 -")
    $("#station_level select:eq(3)").find("option:eq(0)").text("- 变电站 -")
    $("#station_level select:eq(4)").find("option:eq(0)").text("- 间隔单元电压等级 -")
    $("#station_level select:eq(5)").find("option:eq(0)").text("- 间隔单元 -")
    $("#station_level select:eq(6)").find("option:eq(0)").text("- 设备类型 -")
  else if (select_text is "配电") || (select_text is "输电")
    $("#station_level select:eq(2)").find("option:eq(0)").text("- 线路电压等级 -")
    $("#station_level select:eq(3)").find("option:eq(0)").text("- 线路 -")
    $("#station_level select:eq(4)").find("option:eq(0)").text("- 杆塔号电压等级 -")
    $("#station_level select:eq(5)").find("option:eq(0)").text("- 杆塔号 -")
    $("#station_level select:eq(6)").find("option:eq(0)").text("- 部件类型 -")
  else
    $("#station_level select:eq(2)").find("option:eq(0)").text("- 变电站\\线路电压等级 -")
    $("#station_level select:eq(3)").find("option:eq(0)").text("- 变电站\\线路 -")
    $("#station_level select:eq(4)").find("option:eq(0)").text("- 间隔单元\\杆塔号电压等级 -")
    $("#station_level select:eq(5)").find("option:eq(0)").text("- 间隔单元\\杆塔号 -")
    $("#station_level select:eq(6)").find("option:eq(0)").text("- 设备\\部件类型 -")
  if select_index isnt 0
    $.ajax
      type: "GET"
      url: "/special/substation_voltages/#{select_val}"
      dataType: "json"
      success: (data) ->
        if data.length > 0
          for item in data
            option_str = "<option value = #{item.id}>#{item.name}</option>" 
            $(option_str).appendTo("#substation_voltage_id")

# 变电站电压等级选择
$("#substation_voltage_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  select_parent_index = $("#line_id")[0].selectedIndex
  select_parent_val = $("#line_id").find("option:eq(#{select_parent_index})").val()
  $("#station_level select:gt(2)").find("option:gt(0)").remove()
  $("#station_level li div").hide().find("input").val("")
  $("#station_level select:gt(2)").show()
  if select_index isnt 0
    $.ajax
      type: "GET"
      url: "/special/substations/#{select_parent_val}/#{select_val}"
      dataType: "json"
      success: (data) ->
        if data.length > 0
          for item in data
            option_str = "<option value = #{item.id}>#{item.name}</option>" 
            $(option_str).appendTo("#substation_id")

# 变电站选择
$("#substation_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  $("#station_level select:gt(3)").find("option:gt(0)").remove()
  $("#station_level li div").hide().find("input").val("")
  $("#station_level select:gt(3)").show()
  if select_index isnt 0
    $.ajax
      type: "GET"
      url: "/special/device_area_voltages/#{select_val}"
      dataType: "json"
      success: (data) ->
        if data.length > 0
          for item in data
            option_str = "<option value = #{item.id}>#{item.name}</option>" 
            $(option_str).appendTo("#device_area_voltage_id")

# 新增间隔单元电压等级
# $("#new_device_area_voltage img.complete").click ->
  # $div = $(this).parent()
  # $input = $(this).siblings("input")
  # $select = $(this).parent().prev("select")
  # input_val = $input.val()
  # substation_val = $("#substation_id").val()
  # if input_val isnt ""
  #   $.ajax
  #     type: "GET"
  #     url: "/special/add_device_area_voltage/#{substation_val}/#{input_val}"
  #     dataType: "json"
  #     success: (data) ->
  #       option_str = "<option value = #{data.id}>#{data.name}</option>"
  #       $(option_str).appendTo("#device_area_voltage_id")
  #       $input.val("")
  #       $div.hide()
  #       $select.show()
  #       $("#device_area_voltage_id").find("option:last").attr({"selected":true})
  #       select_index = $("#device_area_voltage_id")[0].selectedIndex
  #       select_val = $("#device_area_voltage_id").find("option:eq(#{select_index})").val()
  #       select_parent_index = $("#substation_id")[0].selectedIndex
  #       select_parent_val = $("#substation_id").find("option:eq(#{select_parent_index})").val()
  #       $("#station_level select:gt(4)").find("option:gt(0)").remove() 
  #       if (select_index isnt 0) && (select_index isnt 1)
  #         $.ajax
  #           type: "GET"
  #           url: "/special/device_areas/#{select_parent_val}/#{select_val}"
  #           dataType: "json"
  #           success: (data) ->
  #             option_str = "<option value = ''>新增</option>"
  #             if data.length > 0
  #               for item in data
  #                 option_str += "<option value = #{item.id}>#{item.name}</option>" 
  #             $(option_str).appendTo("#device_area_id")
        

# 间隔单元电压等级选择
$("#device_area_voltage_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  select_parent_index = $("#substation_id")[0].selectedIndex
  select_parent_val = $("#substation_id").find("option:eq(#{select_parent_index})").val()
  $("#station_level select:gt(4)").find("option:gt(0)").remove() 
  $("#station_level li:gt(4) div").hide().find("input").val("")
  $("#station_level select:gt(4)").show()
  if select_index isnt 0
    $.ajax
      type: "GET"
      url: "/special/device_areas/#{select_parent_val}/#{select_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = ''>- 新增 -</option>"
        if data.length > 0
          for item in data
            option_str += "<option value = #{item.id}>#{item.name}</option>" 
        $(option_str).appendTo("#device_area_id")


# 新增间隔单元
$("#new_device_area img.complete").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  substation_id = $("#substation_id").val()
  device_area_voltage_id = $("#device_area_voltage_id").val()
  input_val = encodeURIComponent($input.val())
  if input_val isnt ""
    $.ajax
      type: "GET"
      url: "/special/add_device_area/#{substation_id}/#{device_area_voltage_id}/#{input_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = #{data.id} selected>#{data.device_area_name}</option>" 
        $(option_str).appendTo("#device_area_id")
        $input.val("")
        $div.hide()
        $select.show()
        disable_controls()
        select_index = $("#device_area_id")[0].selectedIndex
        select_val = $("#device_area_id").find("option:eq(#{select_index})").val()
        $("#station_level select:gt(5)").find("option:gt(0)").remove()
        $("#station_level li:gt(5) div").hide().find("input").val("")
        $("#station_level select:gt(5)").show()
        if (select_index isnt 0) && (select_index isnt 1)
          $.ajax
            type: "GET"
            url: "/special/device_types/#{select_val}"
            dataType: "json"
            success: (data) ->
              option_str = "<option value = ''>- 新增 -</option>"
              if data.length > 0
                for item in data
                  option_str += "<option value = #{item.id}>#{item.name}</option>" 
              $(option_str).appendTo("#device_type_id")


# 间隔单元选择
$("#device_area_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  $("#station_level select:gt(5)").find("option:gt(0)").remove()
  $("#station_level li:gt(5) div").hide().find("input").val("")
  $("#station_level select:gt(5)").show()
  if (select_index isnt 0) && (select_index isnt 1)
    $.ajax
      type: "GET"
      url: "/special/device_types/#{select_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = ''>- 新增 -</option>"
        if data.length > 0
          for item in data
            option_str += "<option value = #{item.id}>#{item.name}</option>" 
        $(option_str).appendTo("#device_type_id")
  else if select_index is 1
    $(this).hide()
    $(this).next("div").show().find("input").focus()


# 新增设备类型
$("#new_device_type img.complete").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  input_val = encodeURIComponent($input.val())
  if input_val isnt ""
    $.ajax
      type: "GET"
      url: "/special/add_device_type/#{input_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = #{data.id} selected>#{data.name}</option>" 
        $(option_str).appendTo("#device_type_id")
        $input.val("")
        $div.hide()
        $select.show()  
        disable_controls()
        select_index = $("#device_type_id")[0].selectedIndex
        select_val = $("#device_type_id").find("option:eq(#{select_index})").val()
        select_parent_index = $("#device_area_id")[0].selectedIndex
        select_parent_val = $("#device_area_id").find("option:eq(#{select_parent_index})").val()
        $("#station_level select:gt(6)").find("option:gt(0)").remove()
        $("#station_level li:gt(6) div").hide().find("input").val("")
        $("#station_level select:gt(6)").show()
        if (select_index isnt 0) && (select_index isnt 1)
          $.ajax
            type: "GET"
            url: "/special/model_styles/#{select_parent_val}/#{select_val}"
            dataType: "json"
            success: (data) ->
              option_str = "<option value = ''>- 新增 -</option>"
              if data.length > 0
                for item in data
                  option_str += "<option value = #{item.id}>#{item.name}</option>" 
              $(option_str).appendTo("#model_style_id")

# 设备类型选择
$("#device_type_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  select_parent_index = $("#device_area_id")[0].selectedIndex
  select_parent_val = $("#device_area_id").find("option:eq(#{select_parent_index})").val()
  $("#station_level select:gt(6)").find("option:gt(0)").remove()
  $("#station_level li:gt(6) div").hide().find("input").val("")
  $("#station_level select:gt(6)").show()
  if (select_index isnt 0) && (select_index isnt 1)
    $.ajax
      type: "GET"
      url: "/special/model_styles/#{select_parent_val}/#{select_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = ''>- 新增 -</option>"
        if data.length > 0
          for item in data
            option_str += "<option value = #{item.id}>#{item.name}</option>" 
        $(option_str).appendTo("#model_style_id")
  else if select_index is 1
    $(this).hide()
    $(this).next("div").show().find("input").focus()

# 新增设备型号
$("#new_model_style img.complete").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  input_val = encodeURIComponent($input.val())
  device_type_id = $("#device_type_id").val()
  voltage_level_id = $("#device_area_voltage_id").val()
  if input_val isnt ""
    $.ajax
      type: "GET"
      url: "/special/add_model_style/#{device_type_id}/#{voltage_level_id}/#{input_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = #{data.id} selected>#{data.name}</option>" 
        $(option_str).appendTo("#model_style_id")
        $input.val("")
        $div.hide()
        $select.show()
        disable_controls()
        select_index = $("#model_style_id")[0].selectedIndex
        select_val = $("#model_style_id").find("option:eq(#{select_index})").val()
        select_parent_index = $("#device_area_id")[0].selectedIndex
        select_parent_val = $("#device_area_id").find("option:eq(#{select_parent_index})").val()
        $("#station_level select:gt(7)").find("option:gt(0)").remove()
        $("#station_level li:gt(7) div").hide().find("input").val("")
        $("#station_level select:gt(7)").show()
        if (select_index isnt 0) && (select_index isnt 1)
          $.ajax
            type: "GET"
            url: "/special/devices/#{select_parent_val}/#{select_val}"
            dataType: "json"
            success: (data) ->
              option_str = "<option value = ''>- 新增 -</option>"
              if data.length > 0
                for item in data
                  option_str += "<option value = #{item.id}>#{item.name}(#{item.phasic})</option>" 
              $(option_str).appendTo("#device_id")
# 设备型号选择
$("#model_style_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  select_val = $(this).find("option:eq(#{select_index})").val()
  select_parent_index = $("#device_area_id")[0].selectedIndex
  select_parent_val = $("#device_area_id").find("option:eq(#{select_parent_index})").val()
  $("#station_level select:gt(7)").find("option:gt(0)").remove()
  $("#station_level li:gt(7) div").hide().find("input").val("")
  $("#station_level select:gt(7)").show()
  if (select_index isnt 0) && (select_index isnt 1)
    $.ajax
      type: "GET"
      url: "/special/devices/#{select_parent_val}/#{select_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = ''>- 新增 -</option>"
        if data.length > 0
          for item in data
            option_str += "<option value = #{item.id}>#{item.name}(#{item.phasic})</option>" 
        $(option_str).appendTo("#device_id")
  else if select_index is 1
    $(this).hide()
    $(this).next("div").show().find("input").focus() 

# 新增设备现场名称
$("#new_device img.complete").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  input_val = encodeURIComponent($input.val())
  device_area_id = $("#device_area_id").val()
  model_style_id = $("#model_style_id").val()
  partton = /(.+)(\(.+\))$/
  if partton.test(input_val)
    $.ajax
      type: "GET"
      url: "/special/add_device/#{device_area_id}/#{model_style_id}/#{input_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = #{data.id} selected>#{data.local_scene_name}(#{data.phasic})</option>" 
        $(option_str).appendTo("#device_id")
        $input.val("")
        $div.hide()
        $div.siblings("span").hide()
        $select.show()
        disable_controls()
        select_index = $("#device_id")[0].selectedIndex
        $("#station_level select:gt(8)").find("option:gt(0)").remove()
        $("#station_level li:gt(8) div").hide().find("input").val("")
        $("#station_level select:gt(8)").show()
        if (select_index isnt 0) && (select_index isnt 1)
          $.ajax
            type: "GET"
            url: "/special/part_positions"
            dataType: "json"
            success: (data) ->
              option_str = "<option value = ''>- 新增 -</option>"
              if data.length > 0
                for item in data
                  option_str += "<option value = #{item.id}>#{item.name}</option>" 
              $(option_str).appendTo("#part_position_id")      
  else 
    $div.siblings("span").css({"color":"red"})
# 设备现场名称选择
$("#device_id").change ->
  disable_controls()
  select_index = $(this)[0].selectedIndex
  $("#station_level select:gt(8)").find("option:gt(0)").remove()
  $("#station_level li:gt(8) div").hide().find("input").val("")
  $("#station_level select:gt(8)").show()
  if (select_index isnt 0) && (select_index isnt 1)
    $.ajax
      type: "GET"
      url: "/special/part_positions"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = ''>- 新增 -</option>"
        if data.length > 0
          for item in data
            option_str += "<option value = #{item.id}>#{item.name}</option>" 
        $(option_str).appendTo("#part_position_id")
  else if select_index is 1
    $(this).hide()
    $(this).next("div").show().find("input").focus()  
    $(this).siblings("span").show().css({"color":"#000"})

# 新增部位角度
$("#new_part_position img.complete").click ->
  $div = $(this).parent()
  $input = $(this).siblings("input")
  $select = $(this).parent().prev("select")
  input_val = encodeURIComponent($input.val())
  if input_val isnt ""
    $.ajax
      type: "GET"
      url: "/special/add_part_position/#{input_val}"
      dataType: "json"
      success: (data) ->
        option_str = "<option value = #{data.id} selected>#{data.name}</option>" 
        $(option_str).appendTo("#part_position_id")
        $input.val("")
        $div.hide()
        $select.show()
        disable_controls()
        select_index = $("#part_position_id")[0].selectedIndex
        if (select_index isnt 0) && (select_index isnt 1)
          $("#submit_btn").attr "disabled" : false
          $("input[type='text']").attr "disabled":false
          $("input[type='text']").css "background" : "#fff"
          $(".shape_select").attr "disabled" : false
          $(".index_select").attr "disabled" : false
          $("#dispel_way").attr "disabled" : false
          $("#defect_property").attr "disabled" : false
          $("#excute_situation").attr "disabled" : false
          $("li.temperature").find(".add_img").show()
        else if select_index is 1
          $(this).hide()
          $(this).next("div").show().find("input").focus()
        else
          disable_controls() 

# 部位角度改变后
$("#part_position_id").change ->
  select_index = $(this)[0].selectedIndex
  if (select_index isnt 0) && (select_index isnt 1)
    $("#submit_btn").attr "disabled" : false
    $("input[type='text']").attr "disabled":false
    $("input[type='text']").css "background" : "#fff"
    $(".shape_select").attr "disabled" : false
    $(".index_select").attr "disabled" : false
    $("#dispel_way").attr "disabled" : false
    $("#defect_property").attr "disabled" : false
    $("#excute_situation").attr "disabled" : false
    $("li.temperature").find(".add_img").show()
  else if select_index is 1
    disable_controls()
    $(this).hide()
    $(this).next("div").show().find("input").focus()
  else
    disable_controls()

# 增加最高温度输入框
$(".add_img").live 'click', ->
  li_temperature = $(this).parent().parent() 
  index = $(this).parent().parent().index()
  index = index - 4
  clone_index = index - 1
  add_li = "<li class='temperature'>
              <span class='shape_span'>
                <select class='shape_select'>
                  <option selected='selected' value='R'>R(矩形)</option>
                  <option value='P'>P(点)</option>
                  <option value='L'>L(线)</option>
                  <option value='E'>E(圆)</option>
                </select>
                <select class='index_select'>
                  <option selected='selected' value='01'>01</option>
                  <option value='02'>02</option>
                  <option value='03'>03</option>
                  <option value='04'>04</option>
                  <option value='05'>05</option>
                  <option value='06'>06</option>
                  <option value='07'>07</option>
                  <option value='08'>08</option>
                  <option value='09'>09</option>
                  <option value='10'>10</option>
                </select>
                最高温度（℃）
              </span>
              <input class='temperature int_float' type='text'/>
              <span class='add_line'>
                <img class='add_img' src='/assets/add.jpg' title='新增'/>
                <img class='delete_img' src='/assets/delete.jpg' title='删除'/>
              </span>
              <span class='warn_message warn_s01_highest_temperature'>格式错误</span>
            </li>"
  $(".items_list_middle").append(add_li)
  $("li.temperature:lt(#{index})").find("img.add_img").hide()
  $("li.temperature:lt(#{index})").find("img.delete_img").show().css({"left":"-5px"})
  if $("li.temperature").length > 1
    index = $("li.temperature").length-1
    $("li.temperature:eq(#{index})").find("img.add_img").show()
    $("li.temperature:eq(#{index})").find("img.delete_img").css({"display":"block","left":"20px"})

# 删除最高温度输入框
$(".delete_img").live 'click', ->
  $(this).parent().parent().remove()
  index = $("li.temperature").length - 1
  if $("li.temperature").length < 2
    $("li.temperature:eq(0)").find("img.delete_img").hide()
    $("li.temperature:eq(0)").find("img.add_img").show()
  else
    $("li.temperature:eq(#{index})").find("img.add_img").show()
    $("li.temperature:eq(#{index})").find("img.delete_img").css({"left":"20px"})


# 分析单元最高温度输入
$("input.temperature").live 'blur', ->
  li_temperature = $(this).parent()
  li_temperature.find(".append_input").remove()
  input_value = $(this).val()
  shape_value = $(this).siblings("span.shape_span").find(".shape_select").val()
  index_value = $(this).siblings("span.shape_span").find(".index_select").val()
  input_name = "cell\[#{shape_value}#{index_value}\[Max\]\]"
  if input_value isnt ""
    input_str = "<input type='hidden' name=#{input_name} value=#{input_value} class = 'append_input'>"
    $(input_str).appendTo(li_temperature)

$("select.shape_select").live 'change', ->
  li_temperature = $(this).parent().parent()
  input_value = $(this).parent().siblings("input.temperature").val()
  shape_value = $(this).val()
  index_value = $(this).siblings().val()
  input_name = shape_value + index_value + "\[Max\]"
  if input_value isnt ""
    li_temperature.find(".append_input").attr({"name":input_name,"value":input_value})

$("select.index_select").live 'change', ->
  li_temperature = $(this).parent().parent()
  input_value = $(this).parent().siblings("input.temperature").val()
  shape_value = $(this).siblings().val()
  index_value = $(this).val()
  input_name = shape_value + index_value + "\[Max\]"
  if input_value isnt ""
    li_temperature.find(".append_input").attr({"name":input_name,"value":input_value})

# 验证日期不为空
$("#detect_date").change ->
  partton = /^(\d{4})\-(\d{2})\-(\d{2})$/
  if $(this).val() is ""
    $(this).siblings("span.detect_date_span").text("加 * 必填").css({"color":"red"}).show()
  else
    if not partton.test($(this).val())
      $(this).siblings("span.detect_date_span").text("格式 yyyy-mm-dd").css({"color":"red"}).show() 
    else    
      $(this).css({"border-color":"#aaa"})
      $(this).siblings("span.detect_date_span").text("加 * 必填").css({"color":"red"}).hide()

# 验证时间
$("#detect_time").blur ->
  partton = /^(([0-2][0-3])|([0-1][0-9])):([0-5][0-9]):([0-5][0-9])$/
  detect_time_value = $(this).val()
  if detect_time_value is ""
    $(this).siblings("span.detect_time_span").text("加 * 必填").css({"color":"red"}).show()
  else
    if partton.test(detect_time_value)
      $(this).css({"border-color":"#aaa"})
      $(this).siblings("span.detect_time_span").hide()
    else
      $(this).siblings("span.detect_time_span").text("格式 hh:mm:ss").css({"color":"red"}).show()

# 验证整数和浮点数格式
$("input.int_float").live 'blur', ->
  int_float = $(this).val()
  if int_float isnt ""
    partton = /^(?:[1-9]\d*|0)(?:\.\d+)?$/
    if partton.test(int_float)
      $(this).css({"border-color":"#aaa"})
      $(this).siblings("span.warn_message").text("格式错误").hide()
    else
      $(this).siblings("span.warn_message").text("格式错误").show()
  else
    $(this).siblings("span.warn_message").text("格式错误").hide()

# 验证消缺日期格式
$("#dispel_time").change ->
  partton = /^(\d{4})\-(\d{2})\-(\d{2})$/
  dispel_time_value = $("#dispel_time").val()
  if (dispel_time_value isnt "") and (not partton.test(dispel_time_value))
    $(this).css({"border-color":"red"}).siblings("span.detect_time_span").css({"color":"red"}).text("格式错误").show()
  else
    $(this).css({"border-color":"#aaa"})
    $(this).siblings("span.warn_message").text("格式错误").hide()
# 提交表单
$("#submit_btn").click ->
  detect_date_value = $("#detect_date").val()
  detect_time_value = $("#detect_time").val()
  dispel_time_value = $("#dispel_time").val()
  int_float = $("input.int_float") 
  partton = /^(\d{4})\-(\d{2})\-(\d{2})$/
  partton1 = /^(([0-2][0-3])|([0-1][0-9])):([0-5][0-9]):([0-5][0-9])$/
  partton2 = /^(?:[1-9]\d*|0)(?:\.\d+)?$/
  unless $("input.file_detail[name=ir_file]").val()?
    $('img#irimage_list').css({"border-color":"red"})
    return false
  if detect_date_value is ""
    $("#detect_date").css({"border-color":"red"}).siblings("span.detect_date_span").css({"color":"red"}).text("加 * 必填").show()
    return false
  if not partton.test(detect_date_value)  
    $("#detect_date").siblings("span.detect_date_span").text("格式 yyyy-mm-dd").css({"color":"red"}).show() 
    return false
  if detect_time_value is ""
    $("#detect_time").css({"border-color":"red"}).siblings("span.detect_time_span").css({"color":"red"}).text("加 * 必填").show()
    return false
  if not partton1.test(detect_time_value)
    $("#detect_time").css({"border-color":"red"}).siblings("span.detect_time_span").css({"color":"red"}).text("格式错误").show()
    return false
  if (dispel_time_value isnt "") and (not partton.test(dispel_time_value))
    $("#dispel_time").css({"border-color":"red"}).siblings("span.detect_time_span").css({"color":"red"}).text("格式错误").show()
    return false
  else
    for item, index in int_float
      int_float_value = item.value
      if (int_float_value isnt "") and (not partton2.test(int_float_value))
        $("input.int_float:eq(#{index})").css({"border-color":"red"}).siblings("span").css({"color":"red"}).text("格式错误").show()
        return false
  if confirm("确认提交？")
    if $.browser.msie
      form = $("form")
      data = form.serializeArray()
      $.ajax
        url: "/special"
        type: "POST"
        data: data
      false
    else
      $("input.int_float").css({"border-color":"#aaa"})
      $(".warn_message").hide()
      return true
  else
    return false

# 清空表单
$("#cancel_btn").click ->
  $("#irimage_list")[0].src = "/assets/display-picture.png"
  # $("#viimage_list")[0].src = "/assets/display-picture.png"
  $("#station_level select:eq(0)").find("option:eq(0)").attr({"selected":true})
  $("#station_level select:gt(0)").find("option:gt(0)").remove()
  $("#station_level select:eq(2)").find("option:eq(0)").text("- 变电站\\线路电压等级 -")
  $("#station_level select:eq(3)").find("option:eq(0)").text("- 变电站\\线路 -")
  $("#station_level select:eq(4)").find("option:eq(0)").text("- 间隔单元\\杆塔号电压等级 -")
  $("#station_level select:eq(5)").find("option:eq(0)").text("- 间隔单元\\杆塔号 -")
  $("#station_level select:eq(6)").find("option:eq(0)").text("- 设备\\部件类型 -")
  $("#station_level select:eq(8)").find("option:eq(0)").text("- 设备现场名称 -")
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
  return false
$ ->
  $station_level_select = $("#station_level select")
  for item in $station_level_select
    item.selectedIndex = 0
  $("#submit_btn").attr "disabled" : true
  $("input[type='text']").attr "disabled" : true
  $("input[type='text']").css "background" : "#eee"
  $(".shape_select").attr "disabled" : true
  $(".index_select").attr "disabled" : true
  $("#dispel_way").attr "disabled" : true
  $("#defect_property").attr "disabled" : true
  $("#excute_situation").attr "disabled" : true
  $("li.temperature").find(".add_img").hide()
  $("#station_level input[type='text']").attr "disabled" : false
  $("#station_level input[type='text']").css "background" : "#fff"

  #初始化控件
  $("#detect_date").datepicker()
  $("#dispel_time").datepicker()

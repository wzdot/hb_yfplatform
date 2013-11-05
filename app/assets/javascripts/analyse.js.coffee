$ ->
  setCookie = (name,value) ->
    days = 1
    exp = new Date()
    exp.setTime(exp.getTime() + days*24*60*60*1000)
    document.cookie = name + "="+ escape (value) + ";expires=" + exp.toGMTString()
  getCookie = (name) ->
    cookie_name = document.cookie
    if cookie_name isnt "" and cookie_name isnt null
      return unescape(cookie_name)
    else
      return null
  checkCookie = ->
    resolution_banner = getCookie()
    if resolution_banner isnt "" and resolution_banner isnt null
      $("#resolution_banner").hide()
    else
      setCookie('name','resolution')
      # 获取屏幕分辨率
      screen_width =  window.screen.width;
      if screen_width < 1280
        $("#resolution_banner").slideDown(500)
        setTimeout('$("#resolution_banner").slideUp(600)',4000)

  checkCookie()

  compare_current_phase_id = null
  compare_ajax_flag = true
  current_phase =  true
  last_id = null

  # 时间控件初始化
  $("#begin_date").datepicker()
  $("#end_date").datepicker()




  # 点击图片放大
  $("#layer").click ->
    $(".styled-select").show()
    $(".areas_select").show()
    $(".picturebox").hide()
    $("#layer").hide()
    $(".picturebox").children("img")[0].src = ""

  $(".closeimg").click ->
    $(".areas_select").show()
    $(".styled-select").show()
    $("#layer").hide()
    $(".picturebox").hide()
    $(".picturebox > img")[0].src = ""

  $("#details_pic > div > img").mouseover ->
    dispath = $(this).attr 'src'
    if dispath isnt "/assets/display-picture.png"
      $(this).css({"cursor":"pointer"})
    else
      $(this).css({"cursor":"default"})

  $("#details_history img").live 'mouseover' , ->
    dispath = $(this).attr 'src'
    if dispath isnt "/assets/display-picture.png"
      $(this).css({"cursor":"pointer"})
    else
      $(this).css({"cursor":"default"})

  $("#details_pic > div > img").click (e) ->
    dispath = $(this).attr 'src'
    if(dispath isnt "/assets/display-picture.png")
      e.cancelBubble = true
      e.stopPropagation()
      strSrc = $(this)[0].src
      $(".picturebox").show 500
      $(".picturebox > img")[0].src = strSrc
      $("#layer").show()
      $(".styled-select").hide()
      $(".areas_select").hide()

  $("#details_history img").live 'click' , (e) ->
    dispath = $(this).attr 'src'
    if(dispath isnt "/assets/display-picture.png")
      e.cancelBubble = true
      e.stopPropagation()
      strSrc = $(this)[0].src
      $(".picturebox").show 500
      $(".picturebox > img")[0].src = strSrc
      $("#layer").show()
      $(".styled-select").hide()
      $(".areas_select").hide()

  # 初始化相别对比，历史对比
  init_data = ->
    $("#description").text("")
    $("#no_history_items").hide()
    compare_current_phase_id = null
    last_id = null
    $(".details_pic table tr").remove()
    $(".pictureAA")[0].src = "/assets/display-picture.png"
    $(".pictureAA")[1].src = "/assets/display-picture.png"
    $(".pictureAA")[2].src = "/assets/display-picture.png"
    $(".phaseAA")[0].innerHTML = ""
    $(".phaseAA")[1].innerHTML = ""
    $(".phaseAA")[2].innerHTML = ""
    $("#next_pic").attr({"disabled":true})
    $("#prev_pic").attr({"disabled":true})
    $("#load_gif").hide()
    $("#item_current p")[0].innerHTML = ""
    $("#item_current img")[0].src = "/assets/display-picture.png"
    $("#item_current table").empty()
    $("#items_history li").remove()


  # 历史对比数据解析函数
  history_compare = ->
    if compare_current_phase_id isnt null && current_phase
      $("#load_gif").show()
      current_phase = false
      $.ajax
        type: "GET"
        url: "/composite/detections/history/"+ compare_current_phase_id
        dataType: "json"
        success: (result) ->
          $("#item_current table").empty()
          $("#items_history li").remove()
          $("#prev_pic").attr({"disabled":true})
          $("#next_pic").attr({"disabled":true})
          $slide_content = $("#details_history_items")
          slide_content_left = $slide_content.css({"left":400})
          current_title = "#{result.current_device.phasic} #{result.current_device.full_time} #{result.current_device.fault_nature}"
          current_src =  result.current_device.irimage
          current_td = result.current_device.params_json
          current_table_thead = "<thead><tr><td title='类型'>类型</td><td title='值'>值</td></tr></thead>"
          $(current_table_thead).appendTo("#item_current table")
          $("<tbody></tbody>").appendTo("#item_current table")
          $("#item_current p").text(current_title)
          $("#item_current img")[0].src = current_src
          for key, value of current_td
            current_table_tbody =  "<tr><td title='#{key}'>#{key}</td><td title='#{value}'>#{value}</td></tr>"
            $(current_table_tbody).appendTo("#item_current table tbody")
          history_items = result.same_device_box
          history_items_length = history_items.length
          if history_items_length < 3
            $("#prev_pic").attr({"disabled":true})
            $("#next_pic").attr({"disabled":true})
          else if history_items_length < 5
            $("#prev_pic").attr({"disabled":true})
            $("#next_pic").attr({"disabled":false})
            compare_ajax_flag = false
          else
            $("#prev_pic").attr({"disabled":true})
            $("#next_pic").attr({"disabled":false})
            compare_ajax_flag = true
          if history_items_length > 0
            $("#no_history_items").hide()
            for item,index in history_items
              history_str = "<li><p>#{item.phasic} #{item.full_time} #{item.fault_nature}</p><img src=#{item.irimage} onerror=\"this.src='/assets/display-picture-error.png'\" height = '225' width = '300'/></li>"
              $(history_str).appendTo("#items_history")
              history_table_thead = "<table><thead><tr><td title='类型'>类型</td><td title='值'>值</td></tr></thead><tbody></tbody></table>"
              $(history_table_thead).appendTo("#items_history li:eq(#{index})")
              for history_key, history_value of item.params_json
                history_table_tbody =  "<tr><td title='#{history_key}'>#{history_key}</td><td title='#{history_value}'>#{history_value}</td></tr>"
                $(history_table_tbody).appendTo("#items_history li:eq(#{index}) table tbody")
          else
            $("#no_history_items").show()
          $("#load_gif").hide()

  # 相别对比
  $("#phase_compare").click ->
    $(this).css({"background":"#fff","color":"#000"}).siblings("#history_compare").css({"background":"none","color":"#fff"})
    $("#details_pic").show()
    $("#prev_next").hide()
    $("#details_history").hide()


  # 历史对比
  $("#history_compare").click ->
    $(this).css({"background":"#fff","color":"#000"}).siblings("#phase_compare").css({"background":"none","color":"#fff"})
    $("#details_pic").hide()
    $("#prev_next").show()
    $("#details_history").show()
    history_compare()

  # 键盘左右键
  $(document).keyup (event) ->
    if event.keyCode is 37
      $slide_content = $("#details_history_items ")
      slide_content_left = $slide_content.css("left")
      slide_content_left = parseInt slide_content_left
      if not $slide_content.is(":animated")
        if slide_content_left is -400
          $("#prev_pic").attr({"disabled":true})
          $slide_content.animate({ left : '+='+800 }, "slow")
          $("#next_pic").attr({"disabled":false})
        else if slide_content_left is 400
          $("#next_pic").attr({"disabled":false})
          $("#prev_pic").attr({"disabled":true})
        else
          $("#next_pic").attr({"disabled":false})
          $("#prev_pic").attr({"disabled":false})
          $slide_content.animate({ left : '+='+800 }, "slow")

    else if event.keyCode is 39
      $slide_content = $("#details_history_items")
      slide_content_left = $slide_content.css("left")
      slide_content_left = parseInt slide_content_left
      slide_content_left = -slide_content_left
      li_length = $slide_content.find("ul li").length
      li_length = Math.ceil(li_length / 2)
      li_width = li_length * 800
      page_num = (slide_content_left + 400)/800 + 2
      if compare_ajax_flag
        $.ajax
          type: "GET"
          url: "/composite/detections/history/#{compare_current_phase_id}/#{page_num}"
          dataType: "json"
          success: (result) ->
            history_items = result.same_device_box
            history_items_length = history_items.length
            if history_items_length < 2
              compare_ajax_flag = false
            if history_items_length > 0
              for item,index in history_items
                index = index + page_num*3 - 1
                history_str = "<li><p>#{item.phasic} #{item.full_time} #{item.fault_nature}</p><img src=#{item.irimage} onerror=\"this.src='/assets/display-picture-error.png'\" height = '225' width = '300'/></li>"
                $(history_str).appendTo("#items_history")
                history_table_thead = "<table><thead><tr><td title='类型'>类型</td><td title='值'>值</td></tr></thead><tbody></tbody></table>"
                $(history_table_thead).appendTo("#items_history li:eq(#{index})")
                for history_key, history_value of item.params_json
                  history_table_tbody =  "<tr><td title='#{history_key}'>#{history_key}</td><td title='#{history_value}'>#{history_value}</td></tr>"
                  $(history_table_tbody).appendTo("#items_history li:eq(#{index}) table tbody")

      if not $slide_content.is(":animated")
        if slide_content_left is li_width-2000
          $slide_content.animate({ left : '-='+800 }, "slow")
          $("#next_pic").attr({"disabled":true})
          $("#prev_pic").attr({"disabled":false})
        else if slide_content_left > li_width-1600
          $("#next_pic").attr({"disabled":true})
          $("#prev_pic").attr({"disabled":false})
        else
          $slide_content.animate({ left : '-='+800 }, "slow")
          $("#next_pic").attr({"disabled":false})
          $("#prev_pic").attr({"disabled":false})


  #鼠标点击事件
  $("#prev_pic").click ->
    $slide_content = $("#details_history_items ")
    slide_content_left = $slide_content.css("left")
    slide_content_left = parseInt slide_content_left
    if not $slide_content.is(":animated")
      if slide_content_left < -800
        $("#next_pic").attr({"disabled":false})
        $("#prev_pic").attr({"disabled":false})
        $slide_content.animate({ left : '+='+800 }, "slow")
      else
        $slide_content.animate({ left : '+='+800 }, "slow")
        $("#next_pic").attr({"disabled":false})
        $("#prev_pic").attr({"disabled":true})

  $("#next_pic").click ->
    $slide_content = $("#details_history_items")
    slide_content_left = $slide_content.css("left")
    slide_content_left = parseInt slide_content_left
    slide_content_left = -slide_content_left
    li_length = $slide_content.find("ul li").length
    li_length = Math.ceil(li_length / 2)
    li_width = li_length * 800
    page_num = (slide_content_left + 400)/800 + 2
    if compare_ajax_flag
      $.ajax
        type: "GET"
        url: "/composite/detections/history/#{compare_current_phase_id}/#{page_num}"
        dataType: "json"
        success: (result) ->
          history_items = result.same_device_box
          history_items_length = history_items.length
          if history_items_length < 2
            compare_ajax_flag = false
          if history_items_length > 0
            for item,index in history_items
              index = 2*page_num + 1 + index
              history_str = "<li><p>#{item.phasic} #{item.full_time} #{item.fault_nature}</p><img src=#{item.irimage} onerror=\"this.src='/assets/display-picture-error.png'\" height = '225' width = '300'/></li>"
              $(history_str).appendTo("#items_history")
              history_table_thead = "<table><thead><tr><td title='类型'>类型</td><td title='值'>值</td></tr></thead><tbody></tbody></table>"
              $(history_table_thead).appendTo("#items_history li:eq(#{index})")
              for history_key, history_value of item.params_json
                history_table_tbody =  "<tr><td title='#{history_key}'>#{history_key}</td><td title='#{history_value}'>#{history_value}</td></tr>"
                $(history_table_tbody).appendTo("#items_history li:eq(#{index}) table tbody")
    if not $slide_content.is(":animated")
      if slide_content_left < li_width-2000
        $slide_content.animate({ left : '-='+800 }, "slow")
        $("#next_pic").attr({"disabled":false})
        $("#prev_pic").attr({"disabled":false})
      else
        $("#next_pic").attr({"disabled":true})
        $slide_content.animate({ left : '-='+800 }, "slow")
        $("#prev_pic").attr({"disabled":false})

  # 变输配选择
  $("#zone").change ->
    zone_value = $(this).val()
    if zone_value is "变电"
      $("#jqgh_list1_substation_name").text("变电站")
      $("#jqgh_list1_device_area_name").text("间隔单元")
      $("#jqgh_list1_device_type_name").text("设备类型")
      $("#jqgh_list1_local_scene_name").text("设备名称备注")
    else if (zone_value is "配电") || (zone_value is "输电")
      $("#jqgh_list1_substation_name").text("线路名称")
      $("#jqgh_list1_device_area_name").text("杆塔号")
      $("#jqgh_list1_device_type_name").text("部件类型")
      $("#jqgh_list1_local_scene_name").text("方向")
    else
      $("#jqgh_list1_substation_name").text("变电站(线路名称)")
      $("#jqgh_list1_device_area_name").text("间隔单元(杆塔号)")
      $("#jqgh_list1_device_type_name").text("设备(部件)类型")
      $("#jqgh_list1_local_scene_name").text("设备名称备注(方向)")

  # 查询按钮点击
  $("#btn_submit").click (e) ->
    e.preventDefault()
    if jQuery("#zone").length > 0
      zone = jQuery("#zone").val()
      if jQuery("#zone")[0].selectedIndex is 0
        zone = ""
      zone = encodeURIComponent(zone)
    else
      zone = ""

    device_type = jQuery("#query_device_type").val()
    voltage_level = jQuery("#query_voltage_level").val()
    device_area = ""
    level = ""
    select_id = ""
    select_parent_id = ""
    tree = $.fn.zTree.getZTreeObj("roleTree")
    nodes = tree.getSelectedNodes()
    if nodes.length > 0
      level = nodes[0].lv
      select_id = nodes[0].id
      select_parent_id = nodes[0].parent_id

    if $("select#areas_select").length > 0
      device_area = $("select#areas_select").val()
    begin_date = jQuery("#begin_date").val()
    end_date = jQuery("#end_date").val()

    checkbox_all = $(".query_defect").children("input")
    checkbox_num = 0

    fault_nature = []
    for item, index in checkbox_all
      fault_nature.push checkbox_all[index].id if item.checked

    jQuery("#list1").jqGrid("setGridParam",
      url: "/composite/detections.json?voltage_level=" + voltage_level + "&zone=" + zone + "&device_type=" + device_type + "&begin_date=" + begin_date + "&end_date="+ end_date + "&device_area=" + device_area + "&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id + "&fault_nature=" + fault_nature
      page: 1
      loadComplete: (data) ->
        if data.data.length > 0
          jQuery("#list1").jqGrid "setSelection", data.data[0].id
        else
          init_data()
        statistics(data.fault_counts)
    ).trigger "reloadGrid"



  # 显示所有按钮点击
  $("#btn_reset").click (e) ->
    if jQuery("#zone").length > 0
      $('#zone').get(0).selectedIndex = 0
    $('#query_voltage_level').get(0).selectedIndex = 0
    $('#query_device_type').get(0).selectedIndex = 0
    if $("#areas_select").length > 0
      $("#areas_select").get(0).selectedIndex = 0
    $("#begin_date").val("")
    $("#end_date").val("")
    level = ""
    select_id = ""
    select_parent_id = ""
    tree = $.fn.zTree.getZTreeObj("roleTree")
    nodes = tree.getSelectedNodes()
    if nodes.length > 0
      level = nodes[0].lv
      select_id = nodes[0].id
      select_parent_id = nodes[0].parent_id
    jQuery("#list1").jqGrid("setGridParam",
      url: "composite/detections.json?&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id
      page: 1
      loadComplete: (data) ->
        if data.data.length > 0
          jQuery("#list1").jqGrid "setSelection", data.data[0].id
        else
          init_data()
        statistics(data.fault_counts)
    ).trigger "reloadGrid"
    checkbox = $(":checkbox")
    y = 0

    while y < checkbox.length
      checkbox[y].checked = false
      y++


  # zTree初始化
  $.ajax
    url: "/composite/detections/role_tree.json"
    type: "get"
    success: (data) ->
      cfg =
        data:
          key:
            title: 'caption'
        view:
          selectedMulti: false
          showTitle: true
        callback:
          beforeClick: remove_clickable
          onClick: select_tree_item
      $.fn.zTree.init $("#roleTree"), cfg, data

      tree = $.fn.zTree.getZTreeObj("roleTree")
      node = tree.getNodeByParam("parent_id", "0")
      tree.selectNode(node)

  # 禁止重复点击zTree
  remove_clickable = (treeId, treeNode, clickFlag) ->
    tree = $.fn.zTree.getZTreeObj("roleTree")
    nodes = tree.getSelectedNodes()
    node = nodes[0]
    if node.tId is treeNode.tId
      return false
    else
      return true

  # 点击zTree查询
  select_tree_item = (event, treeId, treeNode) ->
    $('#begin_date').val('')
    $('#end_date').val('')
    $('#query_voltage_level').get(0).selectedIndex = 0
    $('#query_device_type').get(0).selectedIndex = 0
    level = treeNode.lv
    if level is 1
      $(".zone").show()
      $('#zone').get(0).selectedIndex = 0
    else
      $('#zone').get(0).selectedIndex = 0
      $(".zone").hide()
    select_id = treeNode.id
    select_parent_id = treeNode.parent_id
    line_no = treeNode.line_no
    jQuery("#list1").jqGrid("setGridParam",
      url: "/composite/detections.json?&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id
      type: "post"
      page: 1
      loadComplete: (data) ->
        $("#query_device_type").find("option:gt(0)").remove()
        option_str = ""
        if data.device_type_list.length > 0
          for item in data.device_type_list
            option_str += "<option value='#{item.id}'>#{item.name}</option>"
          $(option_str).appendTo("#query_device_type")
        if data.data.length > 0
          jQuery("#list1").jqGrid "setSelection", data.data[0].id
        else
          init_data()
        user_level = data.user_level
        statistics(data.fault_counts)
        $(".areas_select").remove() if $(".areas_select")
        if user_level < 3
          $("#jqgh_list1_substation_name").text("变电站(线路名称)")
          $("#jqgh_list1_device_area_name").text("间隔单元(杆塔号)")
          $("#jqgh_list1_device_type_name").text("设备(部件)类型")
          $("#jqgh_list1_local_scene_name").text("设备名称备注(方向)")
        else
          if line_no == 1
            $("#jqgh_list1_substation_name").text("变电站")
            $("#jqgh_list1_device_area_name").text("间隔单元")
            $("#jqgh_list1_device_type_name").text("设备类型")
            $("#jqgh_list1_local_scene_name").text("设备名称备注")
          else
            $("#jqgh_list1_substation_name").text("线路名称")
            $("#jqgh_list1_device_area_name").text("杆塔号")
            $("#jqgh_list1_device_type_name").text("部件类型")
            $("#jqgh_list1_local_scene_name").text("方向")
        if user_level == 5
          areas_label_name = ""
          if line_no == 1
            areas_label_name = "间隔单元："
          else
            areas_label_name = "杆塔号："
          areas_select = "<div class='areas_select'><label for='areas_select'>" + areas_label_name + "</label><select id='areas_select'><option value=''>-请选择-</option>"
          for item in data.areas
            areas_select += "<option value='" + item[0] + "'>" + item[1] + "</option>"
          areas_select += "</select></div>"
          $(areas_select).insertAfter("#device_type")
    ).trigger "reloadGrid"



  # 各个缺陷数量显示
  statistics = (data) ->
    $("form#query_defect .query_defect").remove()
    sum = 0
    for item in data
      sum += item.count
      checked = (if item.checked then "checked" else "")
      item = "<div class = 'query_defect'><input type = 'checkbox'" + checked + " id = '" + item.id + "'/><label for = '" + item.id + "'>" + item.name + "</label><span>(" + item.count + ")</span></div>"
      $(item).prependTo("form#query_defect")
    $('#span_defect_total').text(sum)


  # 模版选择函数
  choose_templates = (templates) ->
    $("#choose_templet ul").empty()
    for key, value of templates
      li = "<li id = #{key}>#{value}</li>"
      $('#choose_templet ul').append(li)
    li_length = $("#choose_templet ul li").length
    if li_length > 1
      $("#choose_templet ul li:eq(0)").addClass("first_item")
      $("#choose_templet ul li:eq(#{li_length-1})").addClass("last_item")
    else if li_length is 1
      $("#choose_templet ul li").addClass("one_item")
    else
      $('#choose_templet ul').append("<li class='.one_item' id='no_item'>暂无模版</li>")

  # 格式化时间函数
  format_standard_time = (cellvalue, options, rowObject) ->
    cellvalue = cellvalue.slice(11,19)
    return cellvalue

  # list1右键菜单
  # $("#list1").contextMenu 'list1_menu',
  #   bindings:
  #     delete_data: ->
  #       if confirm("确定删除这条数据？")
  #         page_num = $("#list1").jqGrid('getGridParam', 'page')
  #         if page_num is 1
  #           page_num = 2
  #         else
  #           page_num = page_num
  #         record_num = $('#list1').jqGrid('getGridParam', 'reccount')
  #         rowid = $('#list1').jqGrid('getGridParam', 'selrow')
  #         device_type = jQuery("#query_device_type").val()
  #         voltage_level = jQuery("#query_voltage_level").val()
  #         device_area = ""
  #         level = ""
  #         select_id = ""
  #         select_parent_id = ""
  #         tree = $.fn.zTree.getZTreeObj("roleTree")
  #         nodes = tree.getSelectedNodes()
  #         if nodes.length > 0
  #           level = nodes[0].lv
  #           select_id = nodes[0].id
  #           select_parent_id = nodes[0].parent_id

  #         if $("select#areas_select").length > 0
  #           device_area = $("select#areas_select").val()
  #         begin_date = jQuery("#begin_date").val()
  #         end_date = jQuery("#end_date").val()

  #         checkbox_all = $(".query_defect").children("input")
  #         checkbox_num = 0

  #         fault_nature = []
  #         for item, index in checkbox_all
  #           fault_nature.push checkbox_all[index].id if item.checked
  #         $.ajax
  #           url: "/composite/detections/#{rowid}.json"
  #           type: "delete"
  #           success: (data) ->
  #             if data.success && record_num > 1
  #               jQuery("#list1").jqGrid("setGridParam",
  #                 url: "/composite/detections.json?voltage_level=" + voltage_level + "&device_type=" + device_type + "&begin_date=" + begin_date + "&end_date="+ end_date + "&device_area=" + device_area + "&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id + "&fault_nature=" + fault_nature
  #                 loadComplete: (data) ->
  #                   if data.data.length > 0
  #                     jQuery("#list1").jqGrid "setSelection", data.data[0].id
  #                   else
  #                     init_data()
  #                   statistics(data.fault_counts)
  #               ).trigger "reloadGrid"
  #             else if data.success && record_num is 1
  #               jQuery("#list1").jqGrid("setGridParam",
  #                 url: "/composite/detections.json?voltage_level=" + voltage_level + "&device_type=" + device_type + "&begin_date=" + begin_date + "&end_date="+ end_date + "&device_area=" + device_area + "&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id + "&fault_nature=" + fault_nature
  #                 page: page_num - 1
  #                 loadComplete: (data) ->
  #                   if data.data.length > 0
  #                     jQuery("#list1").jqGrid "setSelection", data.data[0].id
  #                   else
  #                     init_data()
  #                   statistics(data.fault_counts)
  #               ).trigger "reloadGrid"
  #             else
  #               alert '删除失败'
  #       else
  #         return
  #     edit_data: ->
  #       rowid = $('#list1').jqGrid('getGridParam', 'selrow')
  #       location.href = "/special/#{rowid}/edit"
  #     close_menu: ->
  #       $('div.contextMenu').hide()
  #   onContextMenu: (e, menu) ->
  #     td = e.target or e.srcElement
  #     ptr = $(td).parents("tr.jqgrow")[0]
  #     ci = (if not $(td).is("td") then $(td).parents("td:first")[0].cellIndex else td.cellIndex)
  #     ci = $.getAbsoluteIndex(ptr, ci)  if $.browser.msie
  #     if ci >= 1
  #       rowid = ptr.id
  #       $("#list1").setSelection rowid, false
  #       true
  #     else
  #       false
  #   itemStyle:
  #     color: '#000',
  #     backgroundColor: '#ffffff',
  #     border: '1px solid #ccc'
  #   itemHoverStyle:
  #     color: '#000',
  #     backgroundColor: '#fff085',
  #     cursor: 'pointer',
  #     border: '1px solid #ccc'
  # $("#jqContextMenu").addClass("ui-widget ui-widget-content").css "font-size", "12px"

  # 格式化 list1
  $("#list1").jqGrid
    url: "/composite/detections.json"
    datatype: "json"
    height: 250
    rowNum: 10
    viewrecords: false
    rownumbers: true
    rownumWidth: 50
    pager: "#pager1"
    caption: "查询结果"
    autowidth: true
    multiselect: false
    editurl: "/composite/detections.json"
    onPaging: (pgButton)->
      $('div#jqContextMenu').hide().next("div").hide()
    loadComplete: (data) ->
      choose_templates(data.templates)
      statistics(data.fault_counts)
      if data.data.length > 0
        jQuery("#list1").jqGrid "setSelection", data.data[0].id
      else
        init_data()
    onSelectRow: (id) ->

      compare_current_phase_id = id
      current_phase = true

      if id isnt last_id
        if not $("#details_history").is(":hidden")
          history_compare()
      $.ajax
        type: "GET"
        url: "composite/detections/#{id}.json"
        dataType: "json"
        success: (result) ->
          $(".details_pic table").empty()
          $(".pictureAA")[0].src = "/assets/display-picture.png"
          $(".pictureAA")[1].src = "/assets/display-picture.png"
          $(".pictureAA")[2].src = "/assets/display-picture.png"
          $(".phaseAA")[0].innerHTML = ""
          $(".phaseAA")[1].innerHTML = ""
          $(".phaseAA")[2].innerHTML = ""
          same_device_items = result.same_device_phasics
          if same_device_items.length > 0
            $("#description").text("#{result.description}")
            for item, index in same_device_items
              if (item.irimage isnt "") and (item.irimage isnt null)
                $(".pictureAA:eq(#{index})")[0].src = item.irimage
                thead_str = "<thead><tr><td title='类型'>类型</td><td title='值'>值</td></tr></thead>"
                $(thead_str).appendTo(".details_pic table:eq(#{index})")
                $("<tbody></tbody>").appendTo(".details_pic table:eq(#{index})")
              else
                $(".pictureAA:eq(#{index})")[0].src = "/assets/display-picture.png"
              if (item.params_json isnt "") and (item.params_json isnt null)
                params = item.params_json
                for value, key of params
                  tbody_str = "<tr><td title='#{value}'>#{value}</td><td title='#{key}'>#{key}</td></tr>"
                  $(tbody_str).appendTo(".details_pic table:eq(#{index}) tbody")
              if item.phasic isnt null
                $(".phaseAA :eq(#{index})")[0].innerHTML = "#{item.phasic} #{item.full_time} #{item.fault_nature_name}"
              if id.toString() is item.id.toString()
                $(".phaseAA").css color: "black"
                $(".phaseAA:eq(#{index})").css color: "#ec8f00"

      last_id = id
    jsonReader:
      root: "data"
      page: "curpage"
      total: "totalpages"
      records: "totalrecords"
      repeatitems: false
      cell: ""
      id: "0"
    colNames: ["编号", "单位", "日期", "时间", "变电站(线路名称)", "间隔单元(杆塔号)", "设备(部件)类型", "设备名称备注", "相别", "运行电流", "部位角度", "缺陷性质", "消缺情况", "消缺时间", "消缺方式"]
    colModel: [
      name: "id"
      index: "id"
      align: "center"
      width: "0"
      sortable: false
      hidden: true
    ,
      name: "company"
      index: "company"
      align: "center"
      width: "100"
      sortable: false
    ,
      name: "detect_date"
      index: "detect_date"
      align: "center"
      width: "100"
      sortable: false
    ,
      name: "detect_time"
      index: "detect_time"
      align: "center"
      width: "80"
      sortable: false
      formatter: format_standard_time
    ,
      name: "substation_name"
      index: "substation_name"
      align: "center"
      width: "160"
      sortable: false
    ,
      name: "device_area_name"
      index: "device_area_name"
      align: "center"
      width: "120"
      sortable: false
    ,
      name: "device_type_name"
      index: "device_type_name"
      align: "center"
      width: "100"
      sortable: false
    ,
      name: "local_scene_name"
      index: "local_scene_name"
      align: "center"
      width: "140"
      sortable: false
    ,
      name: "device_phasic"
      index: "device_phasic"
      align: "center"
      width: "40"
      sortable: false
    ,
      name: "electrical_current"
      index: "electrical_current"
      align: "center"
      width: "60"
      sortable: false
    ,
      name: "part_position_name"
      index: "part_position_name"
      align: "center"
      width: "60"
      sortable: false
    ,
      name: "fault_nature_name"
      index: "fault_nature_name"
      align: "center"
      width: "60"
      sortable: false
    ,
      name: "execute_case_name"
      index: "execute_case_name"
      align: "center"
      width: "60"
      sortable: false
    ,
      name: "fixed_date"
      index: "fixed_date"
      align: "center"
      width: "60"
      sortable: false
    ,
      name: "fix_method_name"
      index: "fix_method_name"
      align: "center"
      width: "60"
      sortable: false
     ]









# 选中项重新诊断
$("#selected_analyse").click ->
  select_row = jQuery("#list1").jqGrid('getGridParam','selarrrow')
  if select_row.length > 0
    current_row = select_row[0]
    select_row = select_row.toString()
    jQuery("#list1").jqGrid("setGridParam",
      url: "composite/detections/redo/#{current_row}/#{select_row}"
      loadComplete: (data) ->
        if data.data.length > 0
          jQuery("#list1").jqGrid "setSelection", data.data[0].id
        else
          init_data()
        statistics(data.fault_counts)
    ).trigger "reloadGrid"

# 全部重新诊断
$("#all_analyse").click ->
  jQuery("#list1").jqGrid("setGridParam",
    url: "composite/detections/reall"
    loadComplete: (data) ->
      if data.data.length > 0
        jQuery("#list1").jqGrid "setSelection", data.data[0].id
      else
        init_data()
      statistics(data.fault_counts)
  ).trigger "reloadGrid"


# 幻灯片播放按钮点击
$("#btn_slider").click ->
  isIE6 = !!window.ActiveXObject && !window.XMLHttpRequest
  if isIE6
    alert "浏览器版本过低，请升级为IE7.0+版本！"
    return
  if jQuery("#zone").length > 0
    zone = jQuery("#zone").val()
    if zone is "- 请选择 -"
      zone = ""
  else
    zone = ""
  device_type = jQuery("#query_device_type").val()
  voltage_level = jQuery("#query_voltage_level").val()

  device_area = ""
  level = ""
  select_id = ""
  select_parent_id = ""
  tree = $.fn.zTree.getZTreeObj("roleTree")
  nodes = tree.getSelectedNodes()
  if nodes.length > 0
    level = nodes[0].lv
    select_id = nodes[0].id
    select_parent_id = nodes[0].parent_id

  if $("select#areas_select").length > 0
    device_area = $("select#areas_select").val()

  begin_date = jQuery("#begin_date").val()
  end_date = jQuery("#end_date").val()

  checkbox_all = $(".query_defect").children("input")
  checkbox_num = 0

  fault_nature = []
  for item, index in checkbox_all
    fault_nature.push checkbox_all[index].id if item.checked
  location.href = "irp_slider?" + encodeURI("voltage_level=" + voltage_level + "&zone=" + zone + "&device_type=" + device_type + "&begin_date=" + begin_date + "&end_date="+ end_date + "&device_area=" + device_area + "&level=" + level + "&select_id="+ select_id+"&select_parent_id=" + select_parent_id + "&fault_nature=" + fault_nature)


# 打印单页报告
$("#report_part").mouseover ->
  $("#choose_templet").css({"display":"block"})
$("#report_part").mouseleave ->
  $("#choose_templet").css({"display":"none"})
$("#choose_templet li").live 'mouseover', ->
  $(this).css({"background":"#fff085"}).siblings("li").css({"background":"#fff"})

$("#report_s").click (e)->
  templet_id = $("#choose_templet li:eq(0)").attr 'id'
  templet_name = $("#choose_templet li:eq(0)").text()
  selectedId = $("#list1").jqGrid("getGridParam", "selrow")
  if templet_id is 'no_item'
    return
  if selectedId is null
    alert("未选中打印数据！")
    return
  if confirm("确定使用 #{templet_name} 打印单页报告吗？")
    location.href = "/download/report/#{selectedId}/#{templet_id}"
  else
    return

$("#choose_templet li").live 'click', ->
  templet_id = $(this).attr 'id'
  templet_name = $(this).text()
  selectedId = $("#list1").jqGrid("getGridParam", "selrow")
  if templet_id is 'no_item'
    return
  if selectedId is null
    alert("未选中打印数据！")
    return
  if confirm("确定使用 #{templet_name} 打印单页报告吗？")
    location.href = "/download/report/#{selectedId}/#{templet_id}"
  else
    return

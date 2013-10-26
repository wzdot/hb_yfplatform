$ ->
	$("#file_upload_path").val("")

	# upload execl button click function
	$("#file_upload").uploadify
		buttonText: "选择上传文件"
		auto: true
		multi: false
		width: 100
		height: 25
		successTimeout: 30
		buttonClass: "uploadify_btn"
		fileSizeLimit: '5MB'
		swf: "/assets/uploadify.swf"
		uploader: "basic_data/import.json"
		fileTypeExts: '*.xls; *.xlsx'

		onDialogOpen: ->
			$(".progress_bar").css({"width" : 0})
			$(".progress_value").text("")
			$(".upload_btn").attr({"disabled":true}) 
		onUploadSuccess: (file, result, response) ->
			json = $.parseJSON(result)
			$(".filename").attr({"value":json.filename})
			$("#column_three option").css({"color":"#333"})
			$("#file_upload_path").val(file.name)
			data_match(json.cells)	
		onUploadError: (file, errorCode, errorMsg, errorString) ->
			if errorMsg == '401'
				alert '认证已超时，请重新登录。'
				location.href = '/' 
			else
				alert errorString



	upload_flag = false


	# add matched data to column_two function
	# and changed column_one and column_three options's color
	data_match = (data)->

		$(".upload_btn").attr({"disabled":false})
		$('#column_one').empty()
		$('#column_two').empty()

		i = 0 
		while i < data.length
			column_one_value = data[i].value
			column_one_text = data[i].text
			column_one_str = "<option value = '" + column_one_value + "'>" + column_one_text + "</option>"
			$(column_one_str).appendTo("#column_one")
			column_three_le = $("#column_three option").length
			j = 0
			while j < column_three_le
				column_three_value = $("#column_three option")[j].value
				column_three_text = $("#column_three option")[j].text
				if column_one_text is column_three_text
					$("#column_one option")[i].style.color = "#008200"
					$("#column_three option")[j].style.color = "#008200"
					column_two_value = column_three_value + ":" + column_one_value
					column_two_text = column_one_text + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;《————————》&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + column_three_text
					column_two_str = "<option value = '" + column_two_value + "'>" + column_two_text + "</option>"
					$(column_two_str).appendTo("#column_two")
				j++
			i++



	# control add relation button and  delete relation button disabled or not 
	# by listening column_one , column_two and  column_three change or not
	$("#column_one").change ->
		column_one_select = $("#column_one").find("option:selected").length
		column_three_select = $("#column_three").find("option:selected").length
		if column_one_select > 0 && column_three_select > 0 && not upload_flag
		  $("#add_btn").attr({"disabled":false})

	$("#column_two").change ->
		column_two_select = $("#column_two").find("option:selected").length
		# disabled_flag = $(".upload_group .upload_btn").attr({"disabled"})
		if column_two_select > 0 && not upload_flag
			$("#del_btn").attr({"disabled":false})

	$("#column_three").change ->
		column_one_select = $("#column_one").find("option:selected").length
		column_three_select = $("#column_three").find("option:selected").length
		if column_one_select > 0 && column_three_select > 0 && not upload_flag
		  $("#add_btn").attr({"disabled":false})	
	 


	# add relation button click function
	# add option to column_two and change column_one and column_three's selected options's color
	$("#add_btn").click ->
		column_one_value = $("#column_one").find("option:selected").val()
		column_one_text = $("#column_one").find("option:selected").text()

		column_three_text = $("#column_three").find("option:selected").text()
		column_three_value = $("#column_three").find("option:selected").val()

		column_two_le = $("#column_two option").length

		i = 0
		while i < column_two_le
			column_two_value_str = $("#column_two option")[i].value
			column_two_index = column_two_value_str.indexOf(":")
			column_two_value_str = column_two_value_str.substring(0,column_two_index)
			if column_three_value is column_two_value_str
				alert '该标准数据已被匹配'
				$(this).attr({"disabled":true})
				$("#column_one").find("option:selected").attr({"selected":false})
				$("#column_three").find("option:selected").attr({"selected":false})
				return				
			i++

		middle_connect = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;《————————》&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
		column_two_text = column_one_text + middle_connect + column_three_text
		column_two_value = column_three_value + ":" + column_one_value
		column_two_str = "<option value = '"+column_two_value+"'>" + column_two_text + "</option>"
		$(column_two_str).appendTo("#column_two")
		
		$(this).attr({"disabled":true})
		$("#column_one").find("option:selected")[0].style.color = "#008200"
		$("#column_three").find("option:selected")[0].style.color = "#008200"
		$("#column_one").find("option:selected").attr({"selected":false})
		$("#column_three").find("option:selected").attr({"selected":false})



	# delete relation button click function
	# delete option to column_two and change column_one and column_three's selected options's color
	$("#del_btn").click ->
		column_two_value = $("#column_two").find("option:selected").val()
		column_two_index = column_two_value.indexOf(":")

		column_one_value = column_two_value.substring(column_two_index+1)
		column_oneintwo_value = column_two_value.substring(column_two_index)

		column_three_value = column_two_value.substring(0,column_two_index)
		column_three_str = "#column_three option[value="+column_three_value+"]"
		$(column_three_str).css({"color":"#333"})

		$("#column_two").find("option:selected").remove()
		$(this).attr({"disabled":true})

		column_two_str = "#column_two option[value$='" + column_oneintwo_value+"']"
		column_one_str = "#column_one option[value="+ column_one_value + "]"
		if $(column_two_str).length > 0
			$(column_one_str).css({"color":"#008200"})	
		else
			$(column_one_str).css({"color":"#333"})		


	# upload file button click function

	counter = 0

	$(".upload_btn").click ->
		filename = $(".filename")[0].value
		progress_id = filename.substring(0, 32)

		column_two = $("#column_two option")
		column_two_le = column_two.length

		column_three = $("#column_three option")
		column_three_le = column_three.length

		column_two_value = []
		for item,index in column_two
			column_two_value.push column_two[index].value
		upload_value = {"link":column_two_value, "filename":filename}

		if column_two_le isnt column_three_le
			alert '数据未匹配完整'
			return
		else
			$("#add_btn").attr({"disabled":true})
			$("#del_btn").attr({"disabled":true})
			upload_flag = true
			$(this).attr({"disabled":true})
			$('#file_upload').uploadify('disable', true)
			$('.uploadify_btn').css({"color":"#ccc","background":"fff"})
			$(".progress_container").css({"border-color":"#468847"})
			width_progress_bar = $(".progress_bar").css("width")
			width_progress_bar = width_progress_bar.slice(0,width_progress_bar.length-2) 
			width_progress_bar = parseInt(width_progress_bar)

			progress = setInterval (->
				$.ajax
					url: "basic_data/progress/#{progress_id}"
					dataType: "json"
					type: "GET"
					success: (data)->	
						width_progress_bar = $(".progress_bar").css("width")
						width_progress_bar = width_progress_bar.slice(0,width_progress_bar.length-2) 
						width_progress_bar = parseInt(width_progress_bar)	
						if data.ratio is width_progress_bar						
							counter = counter + 1
							if counter is 100
								alert '数据出错！'
								upload_flag = false
								$(".progress_bar").css({"width" : 0})
								$(".progress_value").text("") 
								$(".upload_btn").attr({"disabled":false})
								$('#file_upload').uploadify('disable', false)
								$('.uploadify_btn').css({"color":"#000"})
								clearInterval progress	
								return						
						width_per = data.ratio + "%"
						$(".progress_bar").css({"width" : width_per})
						$(".progress_value").text(width_per)  
						if data.ratio is 100
							clearInterval progress
							upload_flag = false
							$('#file_upload').uploadify('disable', false)
							$('.uploadify_btn').css({"color":"#000"})
							$(".progress_value").text("数据导入完成！")
							$(".progress_container").css({"border-color":"#ccc","background":"fff"})
					error: (data)->
						clearInterval progress
						upload_flag = false
						$(".progress_bar").css({"width" : 0})
						$(".progress_value").text("") 
						$(".upload_btn").attr({"disabled":false})
						$('#file_upload').uploadify('disable', false)
						$('.uploadify_btn').css({"color":"#000"})
						# alert '数据出错！'
			), 200


			$.ajax
				url: "basic_data/execute"
				dataType: "json"
				type: "POST"
				data: upload_value
				success: (data)->
					# alert data





	


	

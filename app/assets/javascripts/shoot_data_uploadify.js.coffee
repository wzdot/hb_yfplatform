$ ->
	$('#start_upload').attr({'disabled':true})
	$('#stop_upload').attr({'disabled':true})
	$('#delete_all').attr({'disabled':true})	
	if navigator.appName is "Microsoft Internet Explorer" 
		$(".upload_warning").show()
	else
		$(".upload_warning").hide()
	queue_flag = true
	delete_all_flag = true    
	$("#start_upload").click ->
		$('#stop_upload').attr({'disabled':false})
		$('#file_upload').uploadify('upload', '*')
		$('#file_upload').uploadify('disable', true)
		$('.uploadify_btn').css({"color":"#888"})
		$('#delete_all').attr({'disabled':true})
		$(this).attr({"disabled":true})
		
	$("#stop_upload").click ->
		$('#file_upload').uploadify('stop')
		$('#start_upload').attr({'disabled':false})
		$('#start_upload').attr({'value':'继续上传'})
		$('#delete_all').attr({'disabled':false})	
		$(this).attr({"disabled":true})
		queue_flag = false

	$("#delete_all").click ->
		$('#file_upload').uploadify('cancel','*')
		$('#file_upload').uploadify('disable', false)
		$('.uploadify_btn').css({"color":"#000"})
		$('#start_upload').attr({'disabled':true})
		$('#stop_upload').attr({'disabled':true})
		$(this).attr({'disabled':true})
		delete_all_flag = false

	# Place all the behaviors and hooks related to the matching controller here.
	# All this logic will automatically be available in application.js.
	# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
	$("#file_upload").uploadify
		buttonText: "选择图片"
		auto: false
		multi: true
		removeCompleted: true
		buttonClass: "uploadify_btn"
		fileSizeLimit: '1MB'
		swf: "/assets/uploadify.swf"
		uploader: "shoot_data/import.json"
		fileTypeExts: '*.jpg; *.irp'
		itemTemplate: "<div id=\"${fileID}\" class=\"uploadify-queue-item\"><div class=\"cancel\"><a href=\"javascript:$('#${instanceID}').uploadify('cancel', '${fileID}')\">X</a></div><span class=\"fileName\">${fileName} (${fileSize})</span><span class=\"data\"></span></div>"
		onSelect: ->
			$('#start_upload').attr({'disabled':false})
			$('#delete_all').attr({'disabled':false})
			$("#complete_count").text(0)
			# $('#file_upload').uploadify('disable', true)
			# $('.uploadify_btn').css({"color":"#ccc"})
		onDialogClose: (queueData) ->
			queue_num = $(".uploadify-queue-item").length
			$('#total_count').text(queue_num)
			$("#complete_count").text(0)
			count = parseInt($('#total_count').text(), 10) + queueData.filesReplaced 
			$('#total_count').text(count)		
		onUploadStart: ->
			$('#file_upload').uploadify('disable', true)
			$('.uploadify_btn').css({"color":"#888"})
		onCancel: (file) ->
			count = parseInt($('#total_count').text(), 10) - 1
			$('#total_count').text(count)
			if count is 0
				$('#file_upload').uploadify('disable', false)
				$('.uploadify_btn').css({"color":"#000"})
				$('#start_upload').attr({'disabled':true})
				$('#stop_upload').attr({'disabled':true})
				$('#delete_all').attr({'disabled':true})
		onClearQueue: (queueItemCount) ->
			$(".uploadify-queue-item").remove()
		onUploadSuccess: (file, result, response) ->
			count = parseInt($('#complete_count').text(), 10) + 1
			$('#complete_count').text(count)
			json = $.parseJSON(result)				
		onQueueComplete: (queueData)->
			if queue_flag 
				$('#file_upload').uploadify('disable', false)
				$('.uploadify_btn').css({"color":"#000"})
				$('#start_upload').attr({'disabled':true})
				$('#stop_upload').attr({'disabled':true})
				if queueData.filesErrored > 0
					alert "上传失败图片有#{queueData.filesErrored}张"
				$('#start_upload').attr({'value':'开始上传'})
			else
				$('#file_upload').uploadify('disable', true)
				$('.uploadify_btn').css({"color":"#888"})
				$('#start_upload').attr({'disabled':false})
				$('#stop_upload').attr({'disabled':true})
				queue_flag = true
				delete_all_flag = true
		onUploadError: (file, errorCode, errorMsg, errorString) ->
			if errorMsg == '401'
				alert '认证已超时，请重新登录。'
				location.href = '/'
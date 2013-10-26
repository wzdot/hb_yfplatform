$ ->
  $.ajax
    url: "/composite/detections/admin_tree.json"
    type: "get"
    success: (data) ->
      cfg = 
        callback:
          beforeClick: remove_clickable
          onClick: select_tree_item
        view:
        	selectedMulti: false
      $.fn.zTree.init $("#roleTree"), cfg, data
      tree = $.fn.zTree.getZTreeObj("roleTree")
      if $(".admin_user_level").length > 0
	      item_id = $(".admin_user_level").text()
	      item_id = parseInt(item_id)
	      tree = $.fn.zTree.getZTreeObj("roleTree")
	      node = tree.getNodeByParam("id",item_id,null)
	      level = node.lv
	      parent_node = node.getParentNode()
	      i = level

	      while i > 3
	      	parent_node = parent_node.getParentNode()
	      	i--
	      tree.expandNode(parent_node,true,true,true)
	      tree.selectNode(node)

select_tree_item = (event, treeId, treeNode) ->
	close_other_nodes(event, treeId, treeNode)
collapse_nodes = (event, treeId, treeNode) ->
	close_other_nodes(event, treeId, treeNode)

remove_clickable = (treeId, treeNode, clickFlag) ->
  tree = $.fn.zTree.getZTreeObj("roleTree")
  nodes = tree.getSelectedNodes()
  for node in nodes
    if node.id == treeNode.id
      return false
  return true

close_other_nodes = (event, treeId, treeNode) ->
	tree = $.fn.zTree.getZTreeObj(treeId)
	parentNode = treeNode.getParentNode()
	return if parentNode == null
	nodes = parentNode.children
	for node in nodes
		if node.id == treeNode.id
			tree.expandNode(node, true, false, false)
		else
			tree.expandNode(node, false, false, false)


$("input.primary").click (e)->
	e.preventDefault()
	email_reg = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
	phone_reg = /(\d{11})|(^[\s]*$)/
	tree = $.fn.zTree.getZTreeObj("roleTree")
	nodes = tree.getNodes()[0]
	email_flag = email_reg.test $(".input input")[1].value
	phone_flag = phone_reg.test $(".input input")[4].value
	# if nodes.length < 1
	# 	# alert('请选择区域权限')
	# 	# return
	# else
	level = nodes.lv
	parent_id = nodes.parent_id
	item_id = nodes.id
	newuser_input = $(".input input")
	if newuser_input[0].value is ""
		alert '用户名不能为空'
		return
	else if not email_flag
		alert '请填写正确的邮箱地址'
		return
	else if newuser_input[2].value.length < 6
		alert '密码长度不少于6位'
		return
	else if newuser_input[2].value isnt newuser_input[3].value
		alert '两次输入密码不匹配'
		return
	
	else if not phone_flag
		alert '请填写正确的手机号码'
		return
	else
	  $.ajax
	    url: "/admin/users/add_role_user"
	    type: "post"
	    data: {"level": level, "item_id": item_id, "parent_id": parent_id, "name": newuser_input[0].value, "email": newuser_input[1].value, "password": newuser_input[2].value, "mobile": newuser_input[4].value, "admin": newuser_input[5].checked }
	    success: (data) ->
	    	if data.status
	    		alert '成功新建用户！'
	    		location.href = "/users_center/"
	    	else
	    		alert '新建用户失败！'
		    
$("input.edit_user").click (e)->
	e.preventDefault()
	email_reg = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
	phone_reg = /(\d{11})|(^[\s]*$)/
	tree = $.fn.zTree.getZTreeObj("roleTree")
	nodes = tree.getNodes()[0]
	email_flag = email_reg.test $(".input input")[1].value
	phone_flag = phone_reg.test $(".input input")[4].value
	# if nodes.length < 1
	# 	# alert('请选择区域权限')
	# 	# return
	# else
	level = nodes.lv
	parent_id = nodes.parent_id
	item_id = nodes.id
	newuser_input = $(".input input")
	if newuser_input[0].value is ""
		alert '用户名不能为空'
		return
	else if not email_flag
		alert '请填写正确的邮箱地址'
		return
	else if (newuser_input[2].value.length < 6 && newuser_input[2].value.length > 0)
		alert '密码长度不少于6位'
		return
	else if newuser_input[2].value isnt newuser_input[3].value
		alert '两次输入密码不匹配'
		return
	
	else if not phone_flag
		alert '请填写正确的手机号码'
		return
	else
	  $.ajax
	    url: "/admin/users/edit_role_user"
	    type: "post"
	    data: {"level": level, "item_id": item_id, "parent_id": parent_id, "name": newuser_input[0].value, "email": newuser_input[1].value, "password": newuser_input[2].value, "mobile": newuser_input[4].value, "admin": newuser_input[5].checked }
	    success: (data) ->
	    	if data.status
	    		alert '编辑用户信息成功！'
	    		location.href = "/users_center/"
	    	else
	    		alert '编辑用户信息失败！'			
	

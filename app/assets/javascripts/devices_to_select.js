var before_drop_to_devices_to_select_tree, devices_to_select_tree_setting, get_url_for_devices_to_select_tree, on_devices_to_select_drop;

get_url_for_devices_to_select_tree = function(treeId, treeNode) {
  var cur_node, cur_node_level, level, obj_shoot_sequences_tree, param, selected_nodes,cur_node_parent;
  obj_shoot_sequences_tree = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
  selected_nodes = obj_shoot_sequences_tree.getSelectedNodes();
  if (selected_nodes.length < 1) {
    return "";
  }
  level = void 0;
  if (!treeNode) {
    level = -1;
  } else {

    level = treeNode.level;
  }
  param = void 0;
  if (treeNode) {
    param = treeNode.id;
  } else {
    param = 0;
  }
  if (level < 0) {
    cur_node = selected_nodes[0];
    cur_node_level = cur_node.level;
   /* if (cur_node_level !== 0) {
      return "";
    }else if(cur_node_level === 1){
      cur_node_parent = cur_node.getParentNode();
    }*/
    if(cur_node_level === 0){
      param = cur_node.id
      alert("/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level);
      return "/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level;
    }else if(cur_node_level === 1){
      //alert('a');
      cur_node_parent = cur_node.getParentNode();
      param = cur_node_parent.id;
      return "/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level;
    }else if(cur_node_level === 2){
      cur_node_parent = cur_node.getParentNode();
      cur_node_parent = cur_node_parent.getParentNode();
      param = cur_node_parent.id;
      return "/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level;
    }
    param = cur_node.id;
    return "/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level;
  }
};

before_drop_to_devices_to_select_tree = function(treeId, treeNodes, targetNode, moveType) {

  if (treeId === "shoot_sequences_tree" ) {
    if(targetNode.level === 0 && moveType === "inner" && targetNode.device_area_id === treeNodes[0].device_area_id){
      return true;
    }else if(targetNode.level === 1 && ( moveType === "prev" || moveType === "next") && targetNode.device_area_id === treeNodes[0].device_area_id){
      return true;
     
    }else{
      return false;
    }
    
  }else if(treeId === "devices_to_select_tree" && ( moveType === "prev" || moveType === "next") ) {
          
    return true;

  }else{
    return false;
  }

   
 
  //if (targetNode) {
   //return targetNode.drop !== false;
  //} else {
   // return true;
  //}
};

on_devices_to_select_drop = function(event, treeId, treeNodes, targetNode, moveType) {
   $("#btn_save_shoot_sequence").attr("disabled", false);
  /* var treeObj = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
   var sNodes = treeObj.getSelectedNodes();
   var cur_node_parent = sNodes[0].getParentNode();
   treeObj.selectNode(cur_node_parent);
   if(sNodes[0].level === 1){
    if(cur_node_parent){
      treeObj.selectNode(cur_node_parent);
    }
    
   }else if (sNodes[0].level === 0) {
    treeObj.selectNode(sNodes[0]);
   };*/
     
};

devices_to_select_tree_setting = {
  async: {
    enable: true,
    url: get_url_for_devices_to_select_tree,
    type: "get",
    autoParam: ["id", "name=n", "level=lv"],
    otherParam: {
      otherParam: "devices_to_select_tree"
    }
  },
  edit: {
    enable: true,
    showRemoveBtn: false,
    showRenameBtn: false
  },
  view: {
    selectedMulti: true,
    expandSpeed: ""
  },
  callback: {
    beforeDrop: before_drop_to_devices_to_select_tree,
    onDrop: on_devices_to_select_drop
  }
};

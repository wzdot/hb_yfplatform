var before_drop_to_device_areas_to_select_tree, device_areas_to_select_tree_setting, get_url_for_device_areas_to_select_tree, on_device_areas_to_select_drop;

get_url_for_device_areas_to_select_tree = function(treeId, treeNode) {
  // var level;
  // level = (treeNode ? treeNode.level : -1);
  // return "/task/shoot_sequences/" + get_cur_shoot_sequence_id() + "/get_device_areas_to_select.json?level=" + level;
  return '/task/optional_device_area/' + get_cur_shoot_sequence_id();
};

before_drop_to_device_areas_to_select_tree = function(treeId, treeNodes, targetNode, moveType) {
  /*if (treeId === "device_areas_to_select_tree" ? moveType === "inner" : void 0) {
    return false;
  }
  if (targetNode) {
    return targetNode.drop !== false;
  } else {
    return true;
  }*/
  var treeObj = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
  var nodes = treeObj.getNodes();
  if (treeNodes.length > 0) {
    treeNodes[0].isParent = true;
  }
  if (treeId === "shoot_sequences_tree" ) {
    if(nodes.length > 0 && targetNode.level === 0 && ( moveType === "prev" || moveType === "next")){     
      return true;    
    }else if (nodes.length === 0) {
      return true;
    }else {
      return false;
    }
  }else if(treeId === "device_areas_to_select_tree" && ( moveType === "prev" || moveType === "next")){
    return true;
  }else{
    return false;
  };
};

on_device_areas_to_select_drop = function(event, treeId, treeNodes, targetNode, moveType) {

   $("#btn_save_shoot_sequence").attr("disabled", false);
};

device_areas_to_select_tree_setting = {
  async: {
    enable: true,
    url: get_url_for_device_areas_to_select_tree,
    type: "get",
    autoParam: ["id", "name=n", "level=lv"],
    otherParam: {
      otherParam: "device_areas_to_select_tree"
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
    beforeExpand: beforeExpand,
    onAsyncSuccess: onAsyncSuccess,
    onAsyncError: onAsyncError,
    beforeDrag: beforeDrag,
    beforeDrop: before_drop_to_device_areas_to_select_tree,
    onDrop: on_device_areas_to_select_drop
  }
};

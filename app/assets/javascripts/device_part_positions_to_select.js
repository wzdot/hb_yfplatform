
function get_url_for_part_positions_to_select_tree(treeId, treeNode) {
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
    if(cur_node_level === 1){
      //alert('a');
      cur_node_parent = cur_node.getParentNode()
      param = cur_node_parent.id;
      return "/task/device_area_shoot_sequences/" + param + "/get_devices_to_select.json?level=" + level;
    }
    param = cur_node.id;
    return "/task/device_area_shoot_sequences/" + param + "/get_part_positions_to_select.json?level=" + level;
  }
};


function before_drop_to_part_positions_to_select_tree(treeId, treeNodes, targetNode, moveType) {
  var obj_shoot_sequences_tree = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
  var selected_nodes = obj_shoot_sequences_tree.getSelectedNodes();
  if (treeId === "shoot_sequences_tree" ) {
    if(targetNode.level === 1 && moveType === "inner" && targetNode.device_area_id === treeNodes[0].device_area_id){
      if(selected_nodes[0] === targetNode){
        return true;
      } else if (selected_nodes[0].getParentNode() === targetNode) {
        return true;
      }else{
        return false;
      };
      
    }else if(targetNode.level === 2 && ( moveType === "prev" || moveType === "next") && targetNode.device_area_id === treeNodes[0].device_area_id){
      return true;
     
    }else{
      return false;
    }
    
  }else if(treeId === "device_part_positions_to_select" && ( moveType === "prev" || moveType === "next") ) {

    return true;

  }else{
    return false;
  }
};

function on_device_part_positions_to_select_drop(event, treeId, treeNodes, targetNode, moveType) {
   $("#btn_save_shoot_sequence").attr("disabled", false);
};

var device_part_positions_to_select_tree_setting = {
  async: {
    enable: true,
    url: get_url_for_part_positions_to_select_tree,
    type: "get",
    autoParam: ["id", "name=n", "level=lv"],
    otherParam: {
      otherParam: "part_positions_to_select_tree"
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
    beforeDrop: before_drop_to_part_positions_to_select_tree,
    onDrop: on_device_part_positions_to_select_drop
  }
};

var beforeDrag, before_drop_to_shoot_sequences_tree, get_url_for_shoot_sequences_tree, onSequencesTreeClick, on_remove_shoot_sequence, on_shoot_sequences_drop, shoot_sequences_tree_setting;

// get_url_for_shoot_sequences_tree = function(treeId, treeNode) {
//   // var level, param;
//   // level = (treeNode ? treeNode.level : -1);
//   // param = void 0;
//   // if (level < 0) {
//   //   param = get_cur_shoot_sequence_id();
//   //   return "/task/shoot_sequences/" + param + "/get_device_areas.json?level=" + level;
//   // } else {
//   //   param = (treeNode ? treeNode.id : 0);
//   //   return "/task/device_area_shoot_sequences/" + param + "/get_device_shoot_sequences.json?level=" + level;
//   // }
//   var param = get_cur_shoot_sequence_id();
//   return '/task/selected_shoot_sequence/' + param;
// };




on_remove_shoot_sequence = function(event, treeId, treeNode) {
  $("#btn_save_shoot_sequence").attr("disabled", false);
};

beforeDrag = function(treeId, treeNodes) {
  var i, l;
  i = 0;
  l = treeNodes.length;
  while (i < l) {
    if (treeNodes[i].drag === false) {
      return false;
    }
    i++;
  }
  return true;
};

before_drop_to_shoot_sequences_tree = function(treeId, treeNodes, targetNode, moveType) {
  var b, src_node_type;
  b = (targetNode ? targetNode.drop !== false : true);
  if (!b) {
    return false;
  }
  if (treeId === "shoot_sequences_tree") {
    if(treeNodes[0].level === 0 && ( moveType === "prev" || moveType === "next")){
      return true;
    }else if (treeNodes[0].level === 1 && ( moveType === "prev" || moveType === "next") && targetNode.device_area_id === treeNodes[0].device_area_id ){
      return true;
    }else{
      return false;
    }
  } else {
    return false;
  }
};

on_shoot_sequences_drop = function(event, treeId, treeNodes, targetNode, moveType) {
  //var a_node, i;
  if (treeId === "shoot_sequences_tree") {
   // i = 0;
   // while (i < treeNodes.length) {
      //a_node = treeNodes[i];
      //if (a_node.node_type === "device_area" && a_node.isParent === false) {
       // a_node.isParent = true;
      //}
      //i++;
    //}
    $("#btn_save_shoot_sequence").attr("disabled", false);
  }
};

function filter(node) {
  return (node.level == 1);
}

function filter_a(node) {
  return (node.level == 2);
}

onSequencesTreeClick = function(event, treeId, treeNode, clickFlag) { 
    var zTree = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
    var selectNode = zTree.getSelectedNodes();
    var childrenNodes = [];

  if (treeNode.level === 0) {
    var nodes = zTree.getNodesByFilter(filter,false,selectNode[0]);
    for( var i = 0; i < nodes.length; i++){     
      childrenNodes.push(nodes[i].id);
    }
    $.ajax({
      url:'/task/optional_device/' + selectNode[0].id + '/' + childrenNodes,
      type: 'GET',
      success: function(data){
        alert(data);
      }
    })
  } else if(treeNode.level === 1){
    var nodes = zTree.getNodesByFilter(filter_a,false,selectNode[0]);
    for(var i = 0; i < nodes.length; i++){     
      childrenNodes.push(nodes[i].id);
    }
    $.ajax({
      url:'/task/optional_part_position/' + childrenNodes,
      type: 'GET',
      success: function(data){
        alert(data);
      }
    })
  };
  var obj_devices_to_select,obj_device_areas_to_select,obj_device_part_positions_to_select;
  //level = treeNode.level;
  obj_device_part_positions_to_select = $.fn.zTree.getZTreeObj("device_part_positions_to_select_tree");
  obj_device_part_positions_to_select.reAsyncChildNodes(null, "refresh", false);
  obj_devices_to_select = $.fn.zTree.getZTreeObj("devices_to_select_tree");
  obj_devices_to_select.reAsyncChildNodes(null, "refresh", false);
  obj_device_areas_to_select = $.fn.zTree.getZTreeObj("device_areas_to_select_tree");
  obj_device_areas_to_select.reAsyncChildNodes(null, "refresh", false);
};

function beforeRemove(treeId, treeNode) {
  var zTree = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
  zTree.selectNode(treeNode);
  return confirm("确认删除该节点？");
} 

function onRemove(event, treeId, treeNode) {
  if (treeNode.level === 0) {
    var zTree = $.fn.zTree.getZTreeObj("device_areas_to_select_tree");
    var newNode = {name: treeNode.name,tId: treeNode.tId }
    zTree.addNodes(null, newNode);
  }; 
}

shoot_sequences_tree_setting = {
  // async: {
  //   enable: true,
  //   url: get_url_for_shoot_sequences_tree,
  //   type: "get"
  //   //,
  //   // autoParam: ["id", "name", "level"],
  //   // otherParam: {
  //   //   otherParam: "shoot_sequences_tree"
  //   // }
  // },
  edit: {
    enable: true,
    showRemoveBtn: true,
    showRenameBtn: false
  },
  view: {
    selectedMulti: false,
    expandSpeed: ""
  },
  callback: {
    beforeDrop: before_drop_to_shoot_sequences_tree,
    onDrop: on_shoot_sequences_drop,
    onRemove: on_remove_shoot_sequence,
    onClick: onSequencesTreeClick,
    beforeRemove: beforeRemove,
    onRemove: onRemove
  }
};


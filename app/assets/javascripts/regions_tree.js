function onRegionsTreeClick(event, treeId, treeNode, clickFlag) {
  var obj_device_areas_to_select, obj_shoot_sequences_tree, shoot_sequence_id, url,obj_device_to_select,obj_device_part_positions_to_select;
  if (treeNode && treeNode.level < 4) {
    return;
  }
  

  obj_device_areas_to_select = $.fn.zTree.getZTreeObj("device_areas_to_select_tree");
  obj_device_areas_to_select.reAsyncChildNodes(null, "refresh", false);
  
  var param = get_cur_shoot_sequence_id();  
  $.ajax({
    url: '/task/selected_shoot_sequence/' + param, 
    type: "get",
    success:function(data){
      $.fn.zTree.init( $( "#shoot_sequences_tree" ), shoot_sequences_tree_setting, data);
    },
    error:function(){
      alert('数据加载错误');
    }
  }); 

  obj_shoot_sequences_tree = $.fn.zTree.getZTreeObj("shoot_sequences_tree");
  obj_shoot_sequences_tree.reAsyncChildNodes(null, "refresh", false);
  
   
  //清空 devices_to_select_tree
  var obj_devices_to_select_tree = $.fn.zTree.getZTreeObj( "devices_to_select_tree" );
  var devices_to_select_nodes = obj_devices_to_select_tree.getNodes();
  for( var i=0, l = devices_to_select_nodes.length; i < l; i++ ) {
    devices_to_select_nodes = obj_devices_to_select_tree.getNodes();
    obj_devices_to_select_tree.removeNode( devices_to_select_nodes[ 0 ], false );
  }

  //清空 device_part_positions_to_select_tree
  var obj_device_part_positions_to_select_tree = $.fn.zTree.getZTreeObj( "device_part_positions_to_select_tree" );
  var device_part_positions_to_select_nodes = obj_device_part_positions_to_select_tree.getNodes();
  for( var i=0, l = device_part_positions_to_select_nodes.length; i < l; i++ ) {
    device_part_positions_to_select_nodes = obj_device_part_positions_to_select_tree.getNodes();
    obj_device_part_positions_to_select_tree.removeNode( src_nodes[ 0 ], false );
  }

  $("#btn_save_shoot_sequence").attr("disabled", true);
  $("#btn_download_task_pkg").attr("disabled", false);
  shoot_sequence_id = get_cur_shoot_sequence_id();
  url = "#";
  if (shoot_sequence_id) {
    url = "/task/shoot_sequences/download_task_pkg/" + shoot_sequence_id;
  }
  $("#btn_download_task_pkg").attr("href", url);
};


function beforeExpand(treeId, treeNode) {
  if (!treeNode.isAjaxing) {
    ajaxGetNodes(treeNode, "refresh");
    return true;
  } else {
    alert("zTree 正在下载数据中，请稍后展开节点。。。");
    return false;
  }
};


function onAsyncSuccess(event, treeId, treeNode, msg) {
  var zTree;
  if (!msg || msg.length === 0) {
    return;
  }
  zTree = $.fn.zTree.getZTreeObj("regions_tree");
  expandNodes(zTree.getNodes());
};

function expandNodes(nodes) {
  if (!nodes) return;
  curStatus = "expand";
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  for (var i=0, l=nodes.length; i<l; i++) {
    zTree.expandNode(nodes[i], true, false, false);
    if (nodes[i].isParent && nodes[i].zAsync) {
      expandNodes(nodes[i].children);
    } else {
      goAsync = true;
    }
  }
} 

function onAsyncError(event, treeId, treeNode, XMLHttpRequest, textStatus, errorThrown) {
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  alert("异步获取数据出现异常。");
  zTree.updateNode(treeNode);
};

function ajaxGetNodes(treeNode, reloadType) {
  var zTree;
  zTree = $.fn.zTree.getZTreeObj("regions_tree");
  if (reloadType === "refresh") {
    //treeNode.icon = "" + (asset_path('loading.gif'));
    zTree.updateNode(treeNode);
  }
  zTree.reAsyncChildNodes(treeNode, reloadType, false);
};

function OnRightClick(event, treeId, treeNode) {
  var level;
  var zTree;
  zTree = $.fn.zTree.getZTreeObj("regions_tree");

  var rMenu = $("#rMenu");
  if(treeNode.level == 3){
    zTree.selectNode(treeNode);
    showRMenu(event.clientX, event.clientY,treeNode);
  }else if(treeNode.level == 4){
    zTree.selectNode(treeNode);
    showRMenu(event.clientX, event.clientY,treeNode);
  }
}
function showRMenu(x, y,treeNode) {
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  var rMenu = $("#rMenu");
  $("#rMenu ul").show();
  if (treeNode.level == 3) {
    $("#m_edit").hide();
    $("#m_add").show();
    $("#m_del").hide();
  } else if(treeNode.level == 4) {
    $("#m_edit").show();
    $("#m_add").show();
    $("#m_del").show();
  }
  rMenu.css({"top":y+"px", "left":x+"px", "visibility":"visible"});
  $("body").bind("mousedown", onBodyMouseDown);
}

function hideRMenu() {
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  var rMenu = $("#rMenu");
  if (rMenu) rMenu.css({"visibility": "hidden"});
  $("body").unbind("mousedown", onBodyMouseDown);
}


function onBodyMouseDown(event){
  var rMenu = $("#rMenu");
  if (!(event.target.id == "rMenu" || $(event.target).parents("#rMenu").length>0)) {
    rMenu.css({"visibility" : "hidden"});
  }
}

function addTreeNode() {
  hideRMenu();
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  var parent_node = zTree.getSelectedNodes()[0];
  if (parent_node.level === 3) {
    parent_node = parent_node;
  } else if (parent_node.level === 4) {
    parent_node = parent_node.getParentNode();
  };
  var substation_id = parent_node.id;
  var newNode_name = prompt(" 拍摄顺序名称 ");
  if(newNode_name == null){
    return;
  } 
  var children_nodes =  zTree.getNodesByParam("name", newNode_name, parent_node);
  if(children_nodes.length > 0){
    alert("拍摄顺序已存在！");
    newNode_name = prompt(" 拍摄顺序名称 ");
  }

  $.ajax({
    url: '/task/deal_tree_items/add/' + substation_id + '/' +newNode_name,
    type:'GET',
    success: function(data) {
      if(data.status === 0){
          zTree.addNodes(parent_node, data);
        } else {
          alert('数据出错');
        }    
     },
    error: function(){
       alert('数据出错');
     }
   });
}


function removeTreeNode() {
  hideRMenu();
  var zTree = $.fn.zTree.getZTreeObj("regions_tree");
  var nodes = zTree.getSelectedNodes();
  var nodes_id = nodes[0].id;
  if (nodes && nodes.length>0) {
    $.ajax({
      url: '/task/deal_tree_items/delete/'+ nodes_id,
      type:'GET',
      success: function(data) {
        if (data.status === 0) {
          zTree.removeNode(nodes[0]);
        };
      },
      error: function(){
        alert('数据出错');
      }
    });
  };
}

function edit() {
  hideRMenu();
  var zTree = $.fn.zTree.getZTreeObj("regions_tree"),nodes = zTree.getSelectedNodes(),treeNode = nodes[0];
  if (nodes.length == 0) {
    alert("请先选择一个节点");
    return;
  }
  zTree.editName(treeNode); 
}; 

function onRename(event, treeId, treeNode){
  var substation_id = treeNode.id;
  $.ajax({
    url: '/task/deal_tree_items/edit/'+ substation_id + '/' + treeNode.name,
    type:'GET',
    success: function(data) {
      if(data.status === 0){
        return;
      }  
    },
    error: function(){
      alert('数据出错');
    }
  });
}

var regions_tree_setting = {
  edit: {
    enable: true,
    showRemoveBtn: false,
    showRenameBtn: false
  },
  view: {
    selectedMulti: false,
    expandSpeed: ""
  },
  callback: {
    onClick: onRegionsTreeClick,
    onRightClick: OnRightClick,
    onRename: onRename
  }
};

$(function(){
  $.ajax({
    url: '/basic_data/regions/load_tree_items', 
    type: "get",
    success:function(data){
      $.fn.zTree.init( $( "#regions_tree" ), regions_tree_setting, data);
    },
    error:function(){
      alert('数据加载错误');
    }
  });  
})




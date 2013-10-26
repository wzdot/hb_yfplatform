//= require regions_tree
//= require shoot_sequences_tree
//= require device_areas_to_select
//= require devices_to_select
//= require device_part_positions_to_select
//= require_self


 //展开收缩待选择设备区等
  $(".toggle_btn").toggle(function(){
    $(this).css({"background-position":"-62px -192px"}).attr({"title":"展开"}).siblings("div.sidebar-nav").slideUp();
  },function(){
    $(this).css({"background-position":"-94px -192px"}).attr({"title":"收起"}).siblings("div.sidebar-nav").slideDown();
  })

    
  $( document ).ready( function() {
    //初始化区域

    //初始化拍摄顺序明细
    

    //初始化待选择设备区
    $.fn.zTree.init( $( "#device_areas_to_select_tree" ), device_areas_to_select_tree_setting );

    //初始化待选择设备
    $.fn.zTree.init( $( "#devices_to_select_tree" ), devices_to_select_tree_setting );

    //初始化待选择设备
    $.fn.zTree.init( $( "#device_part_positions_to_select_tree" ), device_part_positions_to_select_tree_setting );


    //加入所有待选设备区
    $( "#btn_move_all_device_areas_to_shoot_sequence" ).click( function() {
      var obj_target_tree = $.fn.zTree.getZTreeObj( "shoot_sequences_tree" );
      var obj_src_tree = $.fn.zTree.getZTreeObj( "device_areas_to_select_tree" );
      var src_nodes = obj_src_tree.getNodes();
      obj_target_tree.addNodes( null, src_nodes, true );
      
      //清空
      for( var i=0, l = src_nodes.length; i < l; i++ ) {
        src_nodes = obj_src_tree.getNodes();
        obj_src_tree.removeNode( src_nodes[ 0 ], false );
      }

      $( "#btn_save_shoot_sequence" ).attr( "disabled", false );
    });

    //加入所有待选设备
    $( "#btn_move_all_devices_to_shoot_sequence" ).click( function() {
      var obj_target_tree = $.fn.zTree.getZTreeObj( "shoot_sequences_tree" );
      var obj_src_tree = $.fn.zTree.getZTreeObj( "devices_to_select_tree" );
      var src_nodes = obj_src_tree.getNodes();
      
      var selected_nodes =  obj_target_tree.getSelectedNodes();
      if( selected_nodes.length < 1 ) { return; }

      var target_parent_node = selected_nodes[ 0 ];
      if(target_parent_node.level === 0){
        obj_target_tree.addNodes( target_parent_node, src_nodes, false );
      }else if(target_parent_node.level === 1){
        target_parent_node = target_parent_node.getParentNode()
        obj_target_tree.addNodes( target_parent_node, src_nodes, false );
      }
      
      //清空
      for( var i=0, l = src_nodes.length; i < l; i++ ) {
        src_nodes = obj_src_tree.getNodes();
        obj_src_tree.removeNode( src_nodes[ 0 ], false );
      }
    
      $( "#btn_save_shoot_sequence" ).attr( "disabled", false );
    });

    //加入所有待选设备角度
    $( "#btn_move_all_part_positions_to_shoot_sequence" ).click( function() {
      var obj_target_tree = $.fn.zTree.getZTreeObj( "shoot_sequences_tree" );
      var obj_src_tree = $.fn.zTree.getZTreeObj( "device_part_positions_to_select_tree" );
      var src_nodes = obj_src_tree.getNodes();
      
      var selected_nodes =  obj_target_tree.getSelectedNodes();
      if( selected_nodes.length < 1 ) { return; }

      var target_parent_node = selected_nodes[ 0 ];
      obj_target_tree.addNodes( target_parent_node, src_nodes, false );
      
      //清空
      for( var i=0, l = src_nodes.length; i < l; i++ ) {
        src_nodes = obj_src_tree.getNodes();
        obj_src_tree.removeNode( src_nodes[ 0 ], false );
      }
    
      $( "#btn_save_shoot_sequence" ).attr( "disabled", false );
    });

    //保存按钮
    $("#btn_save_shoot_sequence").click( function() {
      var shoot_sequence_id = get_cur_shoot_sequence_id();

      //alert("save");
      var obj_shoot_sequences_tree = $.fn.zTree.getZTreeObj( "shoot_sequences_tree" );
      var nodes = obj_shoot_sequences_tree.getNodes();
      var json_text = JSON.stringify( nodes ); //除了FF,其他的浏览器支持吗？http://www.json.org/js.html
      //alert( json_text );
      //add 2012-9-7
      var obj_devices_to_select,obj_device_areas_to_select,obj_device_part_positions_to_select;
      obj_device_part_positions_to_select = $.fn.zTree.getZTreeObj("device_part_positions_to_select_tree");
      obj_device_part_positions_to_select.reAsyncChildNodes(null, "refresh", false);
      //obj_devices_to_select = $.fn.zTree.getZTreeObj("devices_to_select_tree");
      //obj_devices_to_select.reAsyncChildNodes(null, "refresh", false);
      obj_device_areas_to_select = $.fn.zTree.getZTreeObj("device_areas_to_select_tree");
      obj_device_areas_to_select.reAsyncChildNodes(null, "refresh", false);
      //清空 devices_to_select_tree
      var obj_src_tree = $.fn.zTree.getZTreeObj( "devices_to_select_tree" );
      var src_nodes = obj_src_tree.getNodes();
      for( var i=0, l = src_nodes.length; i < l; i++ ) {
        src_nodes = obj_src_tree.getNodes();
        obj_src_tree.removeNode( src_nodes[ 0 ], false );
      }

      jQuery.ajax({
          url: "/task/shoot_sequences/create_with_json.json",
          type: "POST",
          data: { id: shoot_sequence_id, shoot_sequence_details: json_text },
          dataType: "json",
          beforeSend: function( x ) {
            //alert( "before send" );
            if( x && x.overrideMimeType ) {
              x.overrideMimeType("application/j-son;charset=UTF-8");
            }
          },
          error: function( xhr, status, ex ) {
            //alert( "error" );
            //临时的。本应放在success段中
            var obj_shoot_sequences_tree = $.fn.zTree.getZTreeObj( "shoot_sequences_tree" );
            obj_shoot_sequences_tree.reAsyncChildNodes( null, "refresh", false );

            var obj_device_areas_to_select = $.fn.zTree.getZTreeObj( "device_areas_to_select_tree" );
            obj_device_areas_to_select.reAsyncChildNodes( null, "refresh", false );
          },
          success: function( result ) {
            //post request已成功，但来不到这里
            alert( "Success to save shoot sequences!" );
          }
      }); //jQuery.ajax
    });  //save click

  });

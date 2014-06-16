jQuery ->
  $("#select_module").on 'change', ->
    unless $("#select_module").val() is ""
      $.ajax
        url: "/append_pemodule"
        method: "get"
        data:
          module_selected: $(this).val()
          project_id: $("#project_id").val()
          pbs_project_element_id: $("#select_pbs_project_elements").val()

  $("#select_pbs_project_elements").on 'change', ->
    $.ajax
      url: "/select_pbs_project_elements",
      method: "get"
      data:
        pbs_project_element_id: $(this).val()
        project_id: $("#project_id").val()

  $("#project_security_level").change ->
    $.ajax
      url: "/update_project_security_level"
      data: "project_security_level=" + $(this).val() + "&user_id=" + $("#user_id").val()


  $("#project_security_level_group").change ->
    $.ajax
      url: "/update_project_security_level_group"
      data: "project_security_level=" + $(this).val() + "&group_id=" + $("#group_id").val()


  $("#project_area").change ->
    $.ajax
      url: "/select_categories"
      data: "project_area_selected=" + $(this).val()

  $("#jump_project_id").change ->
    $.ajax
      url: "change_selected_project"
      method: "get"
      data: "project_id=" + $(this).val()
      success: (data) ->
        document.location.href = "dashboard"

  $(".select_ratio").change ->
    $.ajax
      url: "/refresh_ratio_elements"
      method: "GET"
      data: "wbs_activity_ratio_id=" + $(this).val()
      success: (data) ->
        $(".total-ratio").html data

      error: (XMLHttpRequest, testStatus, errorThrown) ->
        alert "Error!"


  $(".select_size_unit").change ->
    $.ajax
      url: "/refresh_value_elements"
      method: "GET"
      data: "size_unit_id=" + $(this).val()

  $("#project_record_number").change ->
    $.ajax
      url: "project_record_number"
      method: "GET"
      data: "nb=" + $(this).val()
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require moment
//= require bootstrap-datetimepicker

window.productIndex = ->
  $ ->
    $(".seeMoreButton").click ->
      data = $(this).attr("data")
      $(".#{data}").toggle()
      no

window.productNewEdit = ->
  imageId = 0
  addImageInput = (type, data) ->
    name = "_image_#{imageId}"
    $("#imageInputs").append(
      "<div id='#{name}' style='clear:both;margin-bottom:10px;overflow:hidden;'>" +
        "<input type='#{type}' name='#{name}' required='required' class='form-control' style='float:left;width:400px;' />" +
        "<button type='button' onclick='$(\"##{name}\").remove();return false;' class='btn btn-danger' style='float:left;margin-left:20px;width:35px'>" +
          "<span class='glyphicon glyphicon-remove'></span>" +
        "</button>" +
      "</div>"
    )
    if type is 'text' and data
      $("input[name=#{name}]").val data
      $("##{name}").prepend("<img src='#{data}' style='float:left;height:50px;'/>");
    imageId++
  window.addImageLink = -> addImageInput("text", null)
  window.addImageUpload = -> addImageInput("file", null)
  window.addImageLinkWithData = (data) -> addImageInput("text", data)
  
        
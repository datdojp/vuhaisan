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
//= require jquery
//= require jquery_ujs
//= require moment

`
Number.prototype.format = function(n, x) {
    var re = '\\d(?=(\\d{' + (x || 3) + '})+' + (n > 0 ? '\\.' : '$') + ')';
    return this.toFixed(Math.max(0, ~~n)).replace(new RegExp(re, 'g'), '$&,');
};
`

window.onFbAsyncInit = (loginPath, logoutRemotePath) ->
  checkLoginStatus = ->
    FB.getLoginStatus (response) ->
      $name = $("#userInfo .fbAccount .name")
      $profilePic = $("#userInfo .fbAccount .profilePic")
      $loginButton = $("#userInfo .fbAccount .loginButton")
      if response.status is 'connected'
        $name.show()
        $profilePic.show()
        $loginButton.hide()
        
        fbId = response.authResponse.userID
        $.ajax(url: "#{loginPath}?fb_id=#{fbId}")

        FB.api "/me", fields:"name,picture", (response) ->
          $name.html(response.name)
          $profilePic.attr("src", response.picture["data"].url)
      else
        $name.hide()
        $profilePic.hide()
        $loginButton.show()
        $loginButton.click -> FB.login();

        $.ajax(url: "#{logoutRemotePath}")

  FB.Event.subscribe 'auth.authResponseChange', (response) ->
    checkLoginStatus()

  checkLoginStatus()

commonAjaxJsCallback = (data) -> eval data

window.home = (addToCartPath) ->
  $("#productList .footer .addToCartButton").click ->
    productId = $(this).attr("data-product-id")
    $.ajax(url: "#{addToCartPath}?product_id=#{productId}&quantity=1").done commonAjaxJsCallback


window.profile = (logoutPath) ->
  $ ->
    $("#logoutButton").click ->
      FB.logout (response) -> location.href = logoutPath
      no


window.cart = (deleteOrderPath, removeFromCartPath, name, email, address, phone) ->
  $ ->
    $("#deleteOrderButton").click ->
      location.href = deleteOrderPath
      no

    $("#cartDetail #orderItems .removeFromCartButton").click ->
      itemId = $(this).attr("data")
      $.ajax(url: "#{removeFromCartPath}?item_id=#{itemId}").done commonAjaxJsCallback

    $("#useProfileCheck").change ->
      $name = $("#deliveryInfo input[name=name]")
      $email = $("#deliveryInfo input[name=email]")
      $address = $("#deliveryInfo input[name=address]")
      $phone = $("#deliveryInfo input[name=phone]")
      if $(this).is(':checked')
        $name.val name
        $name.prop 'readonly', yes
        $email.val email
        $email.prop 'readonly', yes
        $address.val address
        $address.prop 'readonly', yes
        $phone.val phone
        $phone.prop 'readonly', yes
      else
        $name.prop 'readonly', no
        $email.prop 'readonly', no
        $address.prop 'readonly', no
        $phone.prop 'readonly', no

(function($) {
    $.extend({
	    add2cart: function(source_id, target_id, px_per_ms, callback) {
            var source = $('#' + source_id );
            var target = $('#' + target_id );
            var display_image = $('#' + source_id).attr('src');

            var distance = Math.sqrt(
                Math.pow(source.offset().top - target.offset().top, 2) +
                Math.pow(source.offset().left - target.offset().top, 2) );
            var duration = distance * px_per_ms;
      
            $('body').prepend(
                '<div id="'+source_id+'_shadow" style="display: none; background-color: #ddd; border: solid 1px darkgray; position: static; top: 0px; z-index:100000">' +
                    '<img src="' + display_image + '" style="width:100%;height:100%;" />' +
                '</div>');
            var shadow = $('#'+source_id+'_shadow');

            if( !shadow ) {
                alert('Cannot create the shadow div');
            }
      
            shadow
                .width(source.css('width'))
                .height(source.css('height'))
                .css('top', source.offset().top)
                .css('left', source.offset().left)
                .css('opacity', 0.75).show();
            shadow.css('position', 'absolute');
            
            shadow.animate(
                {
                    top: target.offset().top,
                    left: target.offset().left,
                    opacity: 0,
                    width: target.css("width"),
                    height: target.css("height") },
                {
                    duration: duration,
                    easing: 'linear',
                    complete: function() {
                        shadow.remove();
                        if (callback) {
                            callback.call();
                        }
                    }
                }
            );
        }
    });
})(jQuery);

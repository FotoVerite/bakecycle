$(function() {
  'use strict';
  var rowClickHandler = function(e) {
    var target = $(e.target);
    if (target.closest('a, button, input, select, textarea, label').length) {
      return;
    }
    window.document.location = $(this).data('href') || $(this).attr('href');
  };
  $(document).on('click', '.js-clickable-row', rowClickHandler);
});

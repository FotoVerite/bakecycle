$(function() {
  'use strict';
  var rowClickHandler = function(e) {
    var target = $(e.target);
    if (target.parents('a').is('a')) {
      return;
    }
    window.document.location = $(this).attr('href');
  };
  $(document).on('click', '.js-clickable-row', rowClickHandler);
});

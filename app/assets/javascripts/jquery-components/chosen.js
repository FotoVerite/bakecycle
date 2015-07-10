(function() {
  // not waiting for document ready to help reduce the FOUC
  'use strict';
  $('.js-chosen').each(function(index, el) {
    var options = $(el).data('chosen_options') || {};
    options.width = options.width || '100%';
    $(el).chosen(options);
  });
})();

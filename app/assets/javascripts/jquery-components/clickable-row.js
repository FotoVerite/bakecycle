$(function() {
  'use strict';
  var isInteractiveTarget = function(e) {
    return $(e.target).closest('a, button, input, select, textarea, label').length > 0;
  };

  var navigateRow = function($row) {
    window.document.location = $row.data('href') || $row.attr('href');
  };

  $(document).on('click', '.js-clickable-row', function(e) {
    if (isInteractiveTarget(e)) {
      return;
    }
    navigateRow($(this));
  });

  $(document).on('keydown', '.js-clickable-row', function(e) {
    if (e.key !== 'Enter' && e.keyCode !== 13) {
      return;
    }
    if (isInteractiveTarget(e)) {
      return;
    }
    e.preventDefault();
    navigateRow($(this));
  });

  // Rows are visually clickable but weren't reachable by keyboard -- make them
  // focusable so Tab + Enter works the same as clicking. Re-run on turbo:load
  // since Turbo swaps in new page content without a full reload.
  var makeRowsFocusable = function() {
    $('.js-clickable-row:not([tabindex])').attr({ tabindex: 0, role: 'link' });
  };
  makeRowsFocusable();
  document.addEventListener('turbo:load', makeRowsFocusable);
});

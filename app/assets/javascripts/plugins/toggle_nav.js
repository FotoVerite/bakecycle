$(function () {
  $('li.js-subnav-toggle').click(function() {
    $('li.js-subnav-toggle').removeClass('active');
    $(this).addClass('active');
  });
});

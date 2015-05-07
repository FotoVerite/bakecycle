$(function () {
  $('.js-subnav-toggle').on('click', '>span',function() {
    $(this).parent().toggleClass('show-nav');
  });
});

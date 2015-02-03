$(function () {
  $(".js-clickableRow").on("click", function() {
    window.document.location = $(this).attr("href");
  });
});

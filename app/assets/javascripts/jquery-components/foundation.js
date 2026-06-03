$(function() {
  $(document).on("click", "[data-alert] .close", function(event) {
    event.preventDefault();
    $(this).closest("[data-alert]").fadeOut(300, function() {
      $(this).remove();
    });
  });
});

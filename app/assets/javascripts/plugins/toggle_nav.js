(function(){
  "use strict";
  window.BakeCycle = window.BakeCycle || {};
  var BakeCycle = window.BakeCycle;
  BakeCycle.bindToggleNav = function(){
    $('.js-subnav-toggle')
      .removeClass('show-nav')
      .on('click', '>span',function() {
      $(this).parent().toggleClass('show-nav');
    });
  };
})();

// $(BakeCycle.bindToggleNav);

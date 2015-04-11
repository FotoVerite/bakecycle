(function(){
  "use strict";
  var app = window.BakeCycleAngular;

  app.controller('mapCtrl', ['$window', '$scope', function ($window, $scope) {
    $scope.$on('mapInitialized', function (event, map) {
      angular.element($window).bind('resize', function () {
        var resetCenter = debounce(function () {
          var myLatLng = new google.maps.LatLng($scope.center[0], $scope.center[1]);
          return map.setCenter(myLatLng);
        }, 250);
        resetCenter();
      });
    });

    $scope.openMap = function (object, center) {
      $window.open("https://www.google.com/maps?z=12&t=m&q=loc:" + center[0] + "+" + center[1]);
    };

    function debounce(func, wait, immediate) {
      var timeout;
      return function() {
        var context = this, args = arguments;
        var later = function() {
          timeout = null;
          if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
      };
    }
  }]);
})();

(function(){
  "use strict";
  var app = window.BakeCycleAngular;

  app.controller('mapCtrl', ['$window', '$scope', function ($window, $scope) {
    $scope.$on('mapInitialized', function (event, map) {
      var resetCenter = function () {
        var myLatLng = new google.maps.LatLng($scope.center[0], $scope.center[1]);
        map.setCenter(myLatLng);
      };
      resetCenter();
      var onMapResize = debounce(resetCenter, 250)
      angular.element($window).bind('resize', onMapResize);
    });

    $scope.openMap = function (object, center) {
      $window.open("https://www.google.com/maps?z=12&t=m&q=loc:" + center[0] + "+" + center[1]);
    };

    function debounce(func, wait, immediate) {
      var timeout;
      return function debounced() {
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

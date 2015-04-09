var app = angular.module('bakecycle', ['ngMap']);

app.controller("NestedItemCtrl", [ '$scope', function ($scope) {
  var date = new Date();
  $scope.nestedItems = [];

  $scope.add = function () {
    $scope.nestedItems.push({});
  };

  $scope.remove = function ($event) {
    var hiddenElement, parentElementName, target;

    hiddenElement = $event.target.previousElementSibling;
    hiddenElement.value = true;

    parentElementName = "fields";
    target = $event.target;

    while (target.className !== parentElementName) {
      target = target.parentNode;
    }

    target.hidden = true;
  };

  $scope.getRandomId = function ($index) {
    return $index + date.getTime();
  };
}]);

app.controller('RecipeCtrl', [ '$scope', function ($scope) {
  $scope.recipe = {};

  $scope.isInclusion = function () {
    return "inclusion" === $scope.recipe.recipe_type;
  };
}]);

app.controller('OrderCtrl', [ '$scope', function ($scope) {
  $scope.order = {}; // filled by ng-init

  $scope.isTemporary = function () {
    return "temporary" === $scope.order.order_type;
  };

  $scope.setDay = function () {
    var startDate;

    startDate = new Date($scope.order.start_date);
    $scope.weekday = startDate.getUTCDay();

    return $scope.weekday;
  };

  $scope.$watch('order.start_date', $scope.setDay);

  $scope.eqStartDate = function (num) {
    if ($scope.order.order_type === "temporary") {
      if ($scope.weekday !== num) {
        return true;
      }
    }
  };
}]);

app.controller('mapCtrl', [ '$window', '$scope', function ($window, $scope) {
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

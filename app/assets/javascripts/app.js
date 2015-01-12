var app = angular.module('bakecycle', []);

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

(function(){
  "use strict";
  var app = window.BakeCycleAngular;

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
})();

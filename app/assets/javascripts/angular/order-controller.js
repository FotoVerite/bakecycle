(function() {
  'use strict';
  var app = window.BakeCycleAngular;

  app.controller('OrderCtrl', [ '$scope', function($scope) {
    $scope.order = {}; // Filled by ng-init

    $scope.isTemporary = function() {
      return 'temporary' === $scope.order.orderType;
    };

    $scope.setDay = function() {
      var startDate;

      startDate = new Date($scope.order.startDate);
      $scope.weekday = startDate.getUTCDay();

      return $scope.weekday;
    };

    $scope.$watch('order.startDate', $scope.setDay);

    $scope.eqStartDate = function(num) {
      if ('temporary' === $scope.order.orderType && $scope.weekday !== num) {
        return true;
      }
    };
  }]);
})();

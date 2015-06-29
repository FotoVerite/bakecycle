(function() {
  'use strict';
  var app = window.BakeCycleAngular;

  app.controller('NestedItemCtrl', [ '$scope', function($scope) {
    var date = new Date();
    $scope.nestedItems = [];

    $scope.add = function() {
      $scope.nestedItems.push({});
    };

    $scope.remove = function($event) {
      var removeField = $event.target.previousElementSibling;
      removeField.value = true;
      $($event.target).parents('.fields').hide();
    };

    $scope.getRandomId = function($index) {
      return $index + date.getTime();
    };
  }]);
})();

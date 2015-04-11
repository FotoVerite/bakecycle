(function(){
  "use strict";
  var app = window.BakeCycleAngular;

  app.controller("NestedItemCtrl", [ '$scope', function ($scope) {
    var date = new Date();
    $scope.nestedItems = [];

    $scope.add = function () {
      $scope.nestedItems.push({});
    };

    $scope.remove = function ($event) {
      var parentElementName, target;
      var removeField = $event.target.previousElementSibling;
      removeField.value = true;

      parentElementName = "fields";
      target = $event.target;

      while (target.className !== parentElementName) {
        target = target.parentNode;
      }

      $(target).hide();
    };

    $scope.getRandomId = function ($index) {
      return $index + date.getTime();
    };
  }]);
})();

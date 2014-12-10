app = angular.module('bakecycle',[]);

app.controller("NestedItemCtrl", [ '$scope', function($scope){
  var date = new Date();
  $scope.nestedItems = [];

  $scope.add = function() {
    $scope.nestedItems.push({});
  };

  $scope.remove = function($event){
    var hiddenElement, parentElement;

    var hiddenElement = $event.target.previousElementSibling;
    hiddenElement.value = true;

    var parentElement = $event.target.parentNode.parentNode;
    parentElement.hidden = true;
  };

  $scope.getRandomId = function($index) {
   return $index + date.getTime();
  }
}]);

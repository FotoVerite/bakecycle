app = angular.module('bakecycle',[]);

app.controller("RecipeItemCtrl", function($scope){
  var date = new Date();
  $scope.recipeItems = [];

  $scope.isRemovable = function() {
    return true;
  };

  $scope.add = function() {
    $scope.recipeItems.push({});
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
});

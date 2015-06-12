(function() {
  'use strict';
  var app = window.BakeCycleAngular;

  app.controller('RecipeCtrl', [ '$scope', function($scope) {
    $scope.recipe = {};
    $scope.isDough = function() {
      return 'dough' === $scope.recipe.recipeType;
    };
  }]);
})();

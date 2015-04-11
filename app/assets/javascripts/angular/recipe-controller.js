(function(){
  "use strict";
  var app = window.BakeCycleAngular;

  app.controller('RecipeCtrl', [ '$scope', function ($scope) {
    $scope.recipe = {};
    $scope.isInclusion = function () {
      return "inclusion" === $scope.recipe.recipe_type;
    };
  }]);
})();

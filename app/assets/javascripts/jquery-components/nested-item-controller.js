(function() {
  'use strict';

  // This replaces all of angularjs, in the future
  // don't use angular js

  var remove = function(e) {
    e.preventDefault();
    var removeField = e.target.previousElementSibling;
    removeField.value = true;
    $(e.target).parents('.fields').hide();
  };

  var counter = 100000000;
  var getNextId = function() {
    return counter++;
  };

  $(function(){
    var controller = $('[data-controller="NestedItemCtrl"]');
    if (!controller.get(0)) {
      return;
    }

    var repeatedElement = controller.find('[data-repeat]');
    var container = repeatedElement.parent();
    var template = repeatedElement.outerHTML();
    repeatedElement.remove();

    function add(e) {
      e.preventDefault();
      var id = getNextId();
      var newRow = template.replace(/\$\{ID\}/g, id);
      container.append(newRow);
      $('.js-chosen-add').each(function(index, el) {
        var options = $(el).data('chosen_options') || {};
        options.width = options.width || '100%';
        $(el).chosen();
      });
    }

    controller.find('[data-add]').on('click', add);
    controller.on('click', '[data-remove]', remove);

  });
})();

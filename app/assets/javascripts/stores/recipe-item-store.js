var Backbone = require('backbone');
var _ = require('underscore');

var RecipeItem = Backbone.Model.extend({
  defaults: function() {
    var sortId = this.getNumericCID();
    if (this.collection) {
      sortId = this.collection.nextSortId();
    }
    return { sortId };
  },

  getNumericCID: function() {
    return Number(this.cid.substring(1));
  }
});

var RecipeItemStore = Backbone.Collection.extend({
  initialize: function() {
    this.on('change:destroy', this.onToggleDestroy);
  },

  onToggleDestroy: function(model) {
    if (!model.id) {
      this.remove(model);
    }
  },

  model: RecipeItem,

  move: function(cid, targetCid, after) {
    var movedItem = this.get(cid);
    var targetItem = this.get(targetCid);
    if (!movedItem || !targetItem) { return; }
    var sorted = this.without(movedItem);
    var newIndex = _.indexOf(sorted, targetItem);
    if (after) {
      newIndex = newIndex + 1;
    }
    sorted.splice(newIndex, 0, movedItem);
    sorted.forEach((item, index) => item.set({sortId: index}, {silent: true}));
    this.sort();
  },

  nextSortId: function() {
    if (this.length === 0) { return 0; }
    var lastItem = this.max(function(model) {return model.get('sortId');});
    return Number(lastItem.get('sortId')) + 1;
  },

  comparator: 'sortId',

  addBlankForm: function() {
    if (this.length === 0) {
      return this.add({});
    }
    if (this.last().id) {
      this.add({});
    }
  },

});

module.exports = RecipeItemStore;

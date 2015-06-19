var ArrayStore = require('./array-store');
var _ = require('underscore');

module.exports = class RecipeStore extends ArrayStore {
  constructor(initialCollection) {
    super(initialCollection);
  }

  move(id, targetId, after) {
    var movedItem = this.get(id);
    var targetItem = this.get(targetId);
    var sorted = _.chain(this.collection)
      .without(movedItem)
      .sortBy((item) => { return Number(item.sortId); })
      .value();
    var newIndex = _.indexOf(sorted, targetItem);
    if (after) {
      newIndex = newIndex + 1;
    }
    sorted.splice(newIndex, 0, movedItem);
    sorted.forEach((item, index) => { item.sortId = index; });
    this.updateAll(sorted);
  }
};

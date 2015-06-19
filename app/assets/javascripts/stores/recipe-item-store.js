var ArrayStore = require('./array-store');
var _ = require('underscore');

module.exports = class RecipeStore extends ArrayStore {
  constructor(initialCollection) {
    super(initialCollection);
  }

  move(id, targetId, after) {
    var movedItem = this.get(id);
    var targetItem = this.get(targetId);
    if (!movedItem || !targetItem) { return; }
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
    this.emitChange();
  }

  add(newItem, dontEmitChange) {
    newItem = newItem || {};
    if (newItem.sortId === undefined) {
      newItem.sortId = this.nextSortId();
    }
    return super.add(newItem, dontEmitChange);
  }

  nextSortId() {
    if (_.isEmpty(this.collection)) { return 0; }
    return (_(this.collection)
      .max(item => item.sortId)
      .sortId + 1
    );
  }

  map() {
    var sorted = this.sortBy(item => Number(item.sortId));
    return sorted.map.apply(sorted, arguments);
  }
};

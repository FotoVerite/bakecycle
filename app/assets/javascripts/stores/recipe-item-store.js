import Backbone from 'backbone';
import _ from 'underscore';

const RecipeItem = Backbone.Model.extend({
  defaults() {
    const sortId = this.collection ? this.collection.nextSortId() : this.getNumericCID();
    return { sortId };
  },

  getNumericCID() {
    return Number(this.cid.substring(1));
  },

  getError(field) {
    const errors = this.get('errors') || {};
    if (_.isArray(errors[field])) {
      return errors[field][0];
    }
    return errors[field];
  }
});

const RecipeItemStore = Backbone.Collection.extend({
  initialize() {
    this.on('change:destroy', this.onToggleDestroy);
  },

  onToggleDestroy(model) {
    if (!model.id) {
      this.remove(model);
    }
  },

  model: RecipeItem,

  move(cid, targetCid, after) {
    const movedItem = this.get(cid);
    const targetItem = this.get(targetCid);
    if (!movedItem || !targetItem) { return; }
    const sorted = this.without(movedItem);
    let newIndex = _.indexOf(sorted, targetItem);
    if (after) {
      newIndex = newIndex + 1;
    }
    sorted.splice(newIndex, 0, movedItem);
    sorted.forEach((item, index) => item.set({sortId: index}, {silent: true}));
    this.sort();
  },

  nextSortId() {
    if (this.length === 0) { return 0; }
    const lastItem = this.max(function(model) {return model.get('sortId');});
    return Number(lastItem.get('sortId')) + 1;
  },

  comparator: 'sortId',

  addBlankForm() {
    if (this.length === 0) {
      return this.add({});
    }
    if (this.last().id) {
      this.add({});
    }
  }
});

export default RecipeItemStore;

import Backbone from 'backbone';
import { isArray } from 'underscore';

var PriceVarient = Backbone.Model.extend({
  getNumericCID() {
    return Number(this.cid.substring(1));
  },

  getError(field) {
    var errors = this.get('errors') || {};
    if (isArray(errors[field])) {
      return errors[field][0];
    }
    return errors[field];
  }
});

var PricesStore = Backbone.Collection.extend({
  initialize() {
    this.on('change:destroy', this.onToggleDestroy);
  },

  onToggleDestroy(model) {
    if (!model.id) {
      this.remove(model);
    }
  },

  model: PriceVarient,

  addBlankForm() {
    if (this.length === 0) {
      return this.add({});
    }
    if (this.last().id) {
      this.add({});
    }
  }
});

export default PricesStore;

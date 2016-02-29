import { Model, Collection } from 'backbone';
import { isArray } from 'underscore';

export var Order = Model.extend({});

export var OrderItem = Model.extend({
  getError(field) {
    var errors = this.get('errors') || {};
    if (isArray(errors[field])) {
      return errors[field][0];
    }
    return errors[field];
  },

  getNumericCID() {
    return Number(this.cid.substring(1));
  }

});

export var OrderItems = Collection.extend({
  initialize() {
    this.on('change:destroy', this.onToggleDestroy);
  },

  onToggleDestroy(model) {
    if (!model.id) {
      this.remove(model);
    }
  },

  model: OrderItem,

  addBlankForm() {
    if (this.length === 0) {
      return this.add({});
    }
    if (this.last().id) {
      this.add({});
    }
  }
});

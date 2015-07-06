var Backbone = require('backbone');
var _ = require('underscore');

var PriceVarient = Backbone.Model.extend({
  getNumericCID: function() {
    return Number(this.cid.substring(1));
  },

  getError: function(field) {
    var errors = this.get('errors') || {};
    if (_.isArray(errors[field])) {
      return errors[field][0];
    }
    return errors[field];
  }
});

var PricesStore = Backbone.Collection.extend({
  initialize: function() {
    this.on('change:destroy', this.onToggleDestroy);
  },

  onToggleDestroy: function(model) {
    if (!model.id) {
      this.remove(model);
    }
  },

  model: PriceVarient,

  addBlankForm: function() {
    if (this.length === 0) {
      return this.add({});
    }
    if (this.last().id) {
      this.add({});
    }
  },

});

module.exports = PricesStore;

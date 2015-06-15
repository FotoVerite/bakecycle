var EventEmitter = require('events').EventEmitter;

var PriceStore = module.exports = function(initialPrices) {
  this.prices = initialPrices || [];
  this.emitter = new EventEmitter();
};

PriceStore.prototype = {
  updateAll: function(newPrices) {
    this.prices = newPrices;
    this.emitChange();
  },

  add: function() {
    this.prices.push({});
    this.emitChange();
  },

  updatePrice: function(index, newPrice) {
    var price = this.prices[index];
    price.price = newPrice;
    this.emitChange();
  },

  updateQuantity: function(index, newQuantity) {
    var price = this.prices[index];
    price.quantity = newQuantity;
    this.emitChange();
  },

  toggleDestroy: function(index) {
    var prices = this.prices;
    var price = prices[index];
    if (price.id) {
      price.destroy = !price.destroy;
    } else {
      prices.splice(index, 1);
    }
    this.emitChange();
  },

  length: function() {
    return this.prices.length;
  },

  get: function(index) {
    return this.prices[index];
  },

  map: function() {
    return this.prices.map.apply(this.prices, arguments);
  },

  onChange: function(callBack) {
    this.emitter.on('change', callBack);
  },

  emitChange: function() {
    process.nextTick(() => {
      this.emitter.emit('change');
    });
  }
};

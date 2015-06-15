var EventEmitter = require('events').EventEmitter;

module.exports = class ArrayStore {

  constructor(initialCollection) {
    this.collection = initialCollection || [];
    this.emitter = new EventEmitter();
  }

  updateAll(newItem) {
    this.collection = newItem;
    this.emitChange();
  }

  add() {
    this.collection.push({});
    this.emitChange();
  }

  updateField(index, field, newValue) {
    this.collection[index][field] = newValue;
    this.emitChange();
  }

  toggleDestroy(index) {
    var items = this.collection;
    var item = items[index];
    if (item.id) {
      item.destroy = !item.destroy;
    } else {
      items.splice(index, 1);
    }
    this.emitChange();
  }

  length() {
    return this.collection.length;
  }

  get(index) {
    return this.collection[index];
  }

  map() {
    return this.collection.map.apply(this.collection, arguments);
  }

  onChange(callBack) {
    this.emitter.on('change', callBack);
  }

  emitChange() {
    process.nextTick(() => {
      this.emitter.emit('change');
    });
  }
};

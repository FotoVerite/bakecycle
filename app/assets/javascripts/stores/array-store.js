/** @preventMunge */
var EventEmitter = require('events').EventEmitter;
var _ = require('underscore');

module.exports = class ArrayStore {

  constructor(initialCollection) {
    this.collection = [];
    this.index = {};
    this.emitter = new EventEmitter();
    this._nextId = -1;

    if (initialCollection) {
      this.updateAll(initialCollection);
    }
  }

  updateAll(newItems) {
    this.collection = [];
    this.index = {};
    newItems.map((item) => {
      this.add(item, true);
    });
    this.emitChange();
  }

  add(object, dontEmitChange) {
    object = object || {};
    object._id = this.nextId();
    this.collection.push(object);
    this.index[object._id] = object;
    if (!dontEmitChange) {
      this.emitChange();
    }
  }

  updateField(id, field, newValue) {
    this.get(id)[field] = newValue;
    this.emitChange();
  }

  toggleDestroy(id) {
    var item = this.get(id);
    if (item.id) {
      item.destroy = !item.destroy;
    } else {
      this.remove(id);
    }
    this.emitChange();
  }

  remove(id) {
    var obj = this.get(id);
    if (!obj) {
      return;
    }
    delete this.index[id];
    var index = _.indexOf(this.collection, obj);
    if (index !== -1) {
      this.collection.splice(index, 1);
    }
    this.emitChange();
  }

  length() {
    return this.collection.length;
  }

  get(id) {
    return this.index[id];
  }

  getLast() {
    return this.collection[this.collection.length - 1];
  }

  map() {
    return this.collection.map.apply(this.collection, arguments);
  }

  onChange(callBack) {
    this.emitter.on('change', callBack);
  }

  emitChange() {
    this.emitter.emit('change');
  }

  nextId() {
    this._nextId += 1;
    return this._nextId;
  }

  sortBy(callBack) {
    return _.sortBy(this.collection, callBack);
  }

};

import {assert} from 'chai';
import {updateOrderItem, toggleDestroy} from '../actions/order';
import * as types from '../constants/action-types';

describe('updateOrderItem', () => {
  it('casts all non empty strings to numbers', () => {
    assert.isDefined(types.ORDER_ITEM_UPDATE);
    const item = {id: 4};
    assert.deepEqual(updateOrderItem(item, {
      productId: '4',
      string: '',
      destroy: false,
      keep: true,
      undef: undefined,
      nan: 'NaN',
      null: null,
    }), {
      type: types.ORDER_ITEM_UPDATE,
      orderItem: item,
      data: {
        productId: 4,
        string: '',
        destroy: false,
        keep: true,
        undef: undefined,
        nan: undefined,
        null: null,
      }
    });
  });

  it('ignores updates that would produce a NaN', () => {
    const item = {something: 4};
    assert.deepEqual(updateOrderItem(item, {
      something: 'notanumber',
    }), {
      type: types.ORDER_ITEM_UPDATE,
      orderItem: item,
      data: {
        something: 4,
      }
    });

  });
});

describe('toggleDestroy', () => {
  it('toggles destroy if the item has an id', () => {
    assert.isDefined(types.ORDER_ITEM_UPDATE);
    const item = {id: 4};
    assert.deepEqual(toggleDestroy(item), {
      type: types.ORDER_ITEM_UPDATE,
      orderItem: item,
      data: {destroy: true}
    });

    const destroyedItem = {id: 4, destroy: true};
    assert.deepEqual(toggleDestroy(destroyedItem), {
      type: types.ORDER_ITEM_UPDATE,
      orderItem: destroyedItem,
      data: {destroy: false}
    });
  });

  it('removes the item if it has no id', () => {
    assert.isDefined(types.ORDER_ITEM_REMOVE);
    assert.deepEqual(toggleDestroy({foo: 'bar'}), {
      type: types.ORDER_ITEM_REMOVE,
      data: {foo: 'bar'}
    });
  });
});

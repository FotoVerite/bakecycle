import {assert} from 'chai';
import {toggleDestroy} from '../actions/order';
import * as types from '../constants/action-types';

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

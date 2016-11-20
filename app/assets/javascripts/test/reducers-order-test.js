import {assert} from 'chai';
import reducer, {orderItems as orderItemsReducer} from '../reducers/order';
import * as types from '../constants/action-types';

describe('orders reducer', () => {
  it('returns the initial state', () => {
    assert.deepEqual(reducer(undefined, {}), {
      'availableClients': {},
      'availableProducts': {},
      'availableRoutes': {},
      'order': {},
      'orderItems': [{}],
    });
  });

  it('handles ORDER_UPDATE', () => {
    assert.isDefined(types.ORDER_UPDATE);
    assert.deepEqual(
      reducer(undefined, {
        type: types.ORDER_UPDATE,
        data: {
          clientId: 4
        }
      }).order,
      {
        clientId: 4,
      }
    );
  });

  it('handles ORDER_VALIDATE', () => {
    assert.isDefined(types.ORDER_VALIDATE);
    assert.deepEqual(
      reducer(undefined, {
        type: types.ORDER_VALIDATE,
        data: {
          errors: {start_date: ['msg']}
        }
      }).order,
      {
        errors: {start_date: ['msg']}
      }
    );
  });

  it('handles ORDER_ITEM_ADD', () => {
    assert.isDefined(types.ORDER_ITEM_ADD);
    assert.deepEqual(
      orderItemsReducer([{}], {
        type: types.ORDER_ITEM_ADD,
        data: {productId: 4}
      }),
      [
        {},
        {productId: 4},
      ]
    );
  });

  it('handles ORDER_ITEM_UPDATE', () => {
    assert.isDefined(types.ORDER_ITEM_UPDATE);
    const item = {monday: 4};
    assert.deepEqual(
      orderItemsReducer([{}, item, {}], {
        type: types.ORDER_ITEM_UPDATE,
        orderItem: item,
        data: {productId: 4}
      }),
      [
        {},
        {monday: 4, productId: 4},
        {},
      ]
    );
  });

  it('handles ORDER_ITEM_REMOVE', () => {
    assert.isDefined(types.ORDER_ITEM_REMOVE);
    const item = {
      foo: 'bar'
    };
    assert.deepEqual(
      orderItemsReducer([item], {
        type: types.ORDER_ITEM_REMOVE,
        data: item
      }),
      [
        {},
      ]
    );
  });

});

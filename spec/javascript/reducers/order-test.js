import reducer, { orderItems as orderItemsReducer } from '../../../app/assets/javascripts/reducers/order';
import * as types from '../../../app/assets/javascripts/constants/action-types';

describe('order reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      availableClients: {},
      availableProducts: {},
      availableRoutes: {},
      order: {},
      orderItems: [{}],
    });
  });

  it('handles ORDER_UPDATE', () => {
    expect(types.ORDER_UPDATE).toBeDefined();
    expect(
      reducer(undefined, { type: types.ORDER_UPDATE, data: { clientId: 4 } }).order
    ).toEqual({ clientId: 4 });
  });

  it('handles ORDER_VALIDATE', () => {
    expect(types.ORDER_VALIDATE).toBeDefined();
    expect(
      reducer(undefined, { type: types.ORDER_VALIDATE, data: { errors: { start_date: ['msg'] } } }).order
    ).toEqual({ errors: { start_date: ['msg'] } });
  });

  it('handles ORDER_ITEM_ADD', () => {
    expect(types.ORDER_ITEM_ADD).toBeDefined();
    expect(
      orderItemsReducer([{}], { type: types.ORDER_ITEM_ADD, data: { productId: 4 } })
    ).toEqual([{}, { productId: 4 }]);
  });

  it('handles ORDER_ITEM_UPDATE', () => {
    expect(types.ORDER_ITEM_UPDATE).toBeDefined();
    const item = { monday: 4 };
    expect(
      orderItemsReducer([{}, item, {}], { type: types.ORDER_ITEM_UPDATE, orderItem: item, data: { productId: 4 } })
    ).toEqual([{}, { monday: 4, productId: 4 }, {}]);
  });

  it('handles ORDER_ITEM_REMOVE', () => {
    expect(types.ORDER_ITEM_REMOVE).toBeDefined();
    const item = { foo: 'bar' };
    expect(
      orderItemsReducer([item], { type: types.ORDER_ITEM_REMOVE, data: item })
    ).toEqual([{}]);
  });
});

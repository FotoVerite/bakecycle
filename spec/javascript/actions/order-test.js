import {
  updateOrder,
  updateOrderItem,
  addOrderItem,
  removeOrderItem,
  toggleDestroy,
  validateOrderStartDate,
} from '../../../app/assets/javascripts/actions/order';
import * as types from '../../../app/assets/javascripts/constants/action-types';

describe('updateOrder', () => {
  it('returns ORDER_UPDATE with the given data', () => {
    const action = updateOrder({ clientId: 5 });
    expect(action.type).toBe(types.ORDER_UPDATE);
    expect(action.data).toEqual({ clientId: 5 });
  });

  it('does not mutate the original data object', () => {
    const data = { clientId: 5 };
    updateOrder(data);
    expect(data).toEqual({ clientId: 5 });
  });
});

describe('addOrderItem', () => {
  it('returns ORDER_ITEM_ADD with the given data', () => {
    expect(addOrderItem({ productId: 3 })).toEqual({ type: types.ORDER_ITEM_ADD, data: { productId: 3 } });
  });

  it('defaults to empty object when called with no args', () => {
    expect(addOrderItem()).toEqual({ type: types.ORDER_ITEM_ADD, data: {} });
  });
});

describe('removeOrderItem', () => {
  it('returns ORDER_ITEM_REMOVE with the given data', () => {
    const item = { id: 7 };
    expect(removeOrderItem(item)).toEqual({ type: types.ORDER_ITEM_REMOVE, data: item });
  });
});

describe('updateOrderItem', () => {
  it('converts numeric strings to numbers', () => {
    const item = {};
    const action = updateOrderItem(item, { monday: '10', tuesday: '0' });
    expect(action.data.monday).toBe(10);
    expect(action.data.tuesday).toBe(0);
  });

  it('keeps empty string as-is (not coerced)', () => {
    const item = {};
    const action = updateOrderItem(item, { monday: '' });
    expect(action.data.monday).toBe('');
  });

  it('falls back to original item value when string is not a finite number', () => {
    const item = { monday: 5 };
    const action = updateOrderItem(item, { monday: 'abc' });
    expect(action.data.monday).toBe(5);
  });

  it('passes non-string values through unchanged', () => {
    const item = {};
    const action = updateOrderItem(item, { monday: 42, active: true });
    expect(action.data.monday).toBe(42);
    expect(action.data.active).toBe(true);
  });

  it('returns ORDER_ITEM_UPDATE with item reference', () => {
    const item = { id: 1 };
    const action = updateOrderItem(item, { monday: 3 });
    expect(action.type).toBe(types.ORDER_ITEM_UPDATE);
    expect(action.orderItem).toBe(item);
  });
});

describe('toggleDestroy', () => {
  it('calls removeOrderItem when item has no id', () => {
    const item = { productId: 1 };
    const action = toggleDestroy(item);
    expect(action.type).toBe(types.ORDER_ITEM_REMOVE);
  });

  it('sets destroy: true when item has an id and destroy is currently false', () => {
    const item = { id: 10, destroy: false };
    const action = toggleDestroy(item);
    expect(action.type).toBe(types.ORDER_ITEM_UPDATE);
    expect(action.data.destroy).toBe(true);
  });

  it('sets destroy: false when item has an id and destroy is currently true', () => {
    const item = { id: 10, destroy: true };
    const action = toggleDestroy(item);
    expect(action.data.destroy).toBe(false);
  });
});

describe('validateOrderStartDate — end date validation', () => {
  const kickoff_time = '2020-01-01T14:00:00-05:00';

  it('returns end_date error when start is after end', () => {
    const action = validateOrderStartDate({
      id: 1,
      kickoff_time,
      totalLeadDays: 0,
      startDate: '2025-06-10',
      endDate: '2025-06-01',
    });
    expect(action.type).toBe(types.ORDER_VALIDATE);
    expect(action.data.errors.end_date).toEqual(['The end date cannot be before the start date']);
  });

  it('returns no end_date error when start is before end', () => {
    const action = validateOrderStartDate({
      id: 1,
      kickoff_time,
      totalLeadDays: 0,
      startDate: '2025-06-01',
      endDate: '2025-06-10',
    });
    expect(action.data.errors.end_date).toEqual([]);
  });

  it('returns no end_date error when endDate is undefined', () => {
    const action = validateOrderStartDate({
      id: 1,
      kickoff_time,
      totalLeadDays: 0,
      startDate: '2025-06-01',
    });
    expect(action.data.errors.end_date).toEqual([]);
  });
});

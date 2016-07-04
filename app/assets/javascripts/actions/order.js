import * as types from '../constants/action-types';
import mapValues from 'lodash.mapvalues';
import isFinite from 'lodash.isfinite';

export function updateOrder(data) {
  data = Object.assign({}, data);
  return {
    type: types.ORDER_UPDATE,
    data,
  };
}

export function updateOrderItem(orderItem, data) {
  data = mapValues(data, (value, key) => {
    if (typeof value === 'string' && value !== '') {
      value = Number(value);
      if (!isFinite(value)) {
        return orderItem[key];
      }
    }
    return value;
  });
  return {
    type: types.ORDER_ITEM_UPDATE,
    orderItem,
    data,
  };
}

export function addOrderItem(data) {
  data = data || {};
  return {
    type: types.ORDER_ITEM_ADD,
    data,
  };
}

export function removeOrderItem(data) {
  return {
    type: types.ORDER_ITEM_REMOVE,
    data,
  };
}

export function toggleDestroy(data) {
  if (data.id) {
    return updateOrderItem(data, { destroy: !data.destroy});
  } else {
    return removeOrderItem(data);
  }
}

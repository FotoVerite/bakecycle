import * as types from '../constants/action-types';

export function updateOrder(data) {
  data = Object.assign({}, data);
  return {
    type: types.ORDER_UPDATE,
    data,
  };
}

export function updateOrderItem(orderItem, data) {
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

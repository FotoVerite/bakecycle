import { combineReducers } from 'redux';
import without from 'lodash.without';
import * as types from '../constants/action-types';

export var order = (state = {}, action) => {
  if (action.type === types.ORDER_UPDATE) {
    return Object.assign({}, state, action.data);
  }
  return state;
};

export var orderItems = (state = [{}], action) => {
  if (action.type === types.ORDER_ITEM_ADD) {
    const newState = state.slice();
    newState.push(action.data);
    return newState;
  }
  if (action.type === types.ORDER_ITEM_UPDATE) {
    return state.map(function(item){
      if (item === action.orderItem) {
        return Object.assign({}, item, action.data);
      }
      return item;
    });
  }
  if (action.type === types.ORDER_ITEM_REMOVE) {
    const newState = without(state, action.data);
    if (newState.length === 0) {
      newState.push({});
    }
    return newState;
  }
  return state;
};

export var passthrough = (state = {}) => {
  return state;
};

export default combineReducers({
  order,
  orderItems,
  availableClients: passthrough,
  availableRoutes: passthrough,
  availableProducts: passthrough,
});

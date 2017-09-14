import { combineReducers } from 'redux';
import * as types from '../constants/action-types';

export var ingredients = (state = {}, action) => {
  if (action.type === types.INGREDIENT_UPDATE) {
    return state.map(function(item){
      if (item === action.ingredient) {
        return Object.assign({}, item, action.data);
      }
      return item;
    });
  }
  return state;
};

export var filter = (state = {}, action) => {
  if (action.type === types.FILTER_INGREDIENTS) {
    return action.data.filter;
  }
  return state;
};


export var passthrough = (state = {}) => {
  return state;
};

export default combineReducers({
  ingredients,
  filter,
  availableVendors: passthrough
});

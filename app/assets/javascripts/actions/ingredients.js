import * as types from '../constants/action-types';
import mapValues from 'lodash.mapvalues';
import isFinite from 'lodash.isfinite';
import moment from 'moment';

export function updateIngredient(ingredient, data) {
  data.dirty = true;
  return {
    type: types.INGREDIENT_UPDATE,
    ingredient,
    data
  };
}

export function filterIngredients(data) {
  if(data.filter == null) {
    return {
    type: types.FILTER_INGREDIENTS,
    data: {
      filter: []
      }
    }
  }
  return {
    type: types.FILTER_INGREDIENTS,
    data: {
      filter: data.filter.split(',').map(id => (parseInt(id)))
    }
  };
}


export function toggleDestroy(data) {
  if (data.id) {
    return updateOrderItem(data, { destroy: !data.destroy});
  } else {
    return removeOrderItem(data);
  }
}

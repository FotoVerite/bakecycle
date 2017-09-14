import * as types from '../constants/action-types';

export function updateIngredient(ingredient, data) {
  data.dirty = true;
  return {
    type: types.INGREDIENT_UPDATE,
    ingredient,
    data
  };
}

export function filterIngredients(data) {
  if(data.filter == [null] || data.filter == null) {
    return {
      type: types.FILTER_INGREDIENTS,
      data: {
        filter: []
      }
    };
  }
  return {
    type: types.FILTER_INGREDIENTS,
    data: {
      filter: data.filter.split(',').map(id => (parseInt(id)))
    }
  };
}



import {
  updateIngredient,
  filterIngredients,
} from '../../../app/assets/javascripts/actions/ingredients';
import * as types from '../../../app/assets/javascripts/constants/action-types';

describe('updateIngredient', () => {
  it('returns INGREDIENT_UPDATE with ingredient reference and data', () => {
    const ingredient = { id: 1 };
    const action = updateIngredient(ingredient, { name: 'flour' });
    expect(action.type).toBe(types.INGREDIENT_UPDATE);
    expect(action.ingredient).toBe(ingredient);
    expect(action.data.name).toBe('flour');
  });

  it('sets dirty: true on the data', () => {
    const action = updateIngredient({}, { name: 'sugar' });
    expect(action.data.dirty).toBe(true);
  });
});

describe('filterIngredients', () => {
  it('parses comma-separated ids into integers', () => {
    const action = filterIngredients({ filter: '1,2,3' });
    expect(action.type).toBe(types.FILTER_INGREDIENTS);
    expect(action.data.filter).toEqual([1, 2, 3]);
  });

  it('returns empty filter when filter is null', () => {
    const action = filterIngredients({ filter: null });
    expect(action.data.filter).toEqual([]);
  });

  it('handles a single id', () => {
    const action = filterIngredients({ filter: '42' });
    expect(action.data.filter).toEqual([42]);
  });
});

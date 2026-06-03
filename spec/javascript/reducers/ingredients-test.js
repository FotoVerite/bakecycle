import reducer, { ingredients, filter } from '../../../app/assets/javascripts/reducers/ingredients';
import * as types from '../../../app/assets/javascripts/constants/action-types';

describe('ingredients reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, {})).toEqual({
      ingredients: {},
      filter: {},
      weightUnitOptions: {},
    });
  });

  it('handles INGREDIENT_UPDATE', () => {
    const item = { id: 1, name: 'flour' };
    const state = [item, { id: 2 }];
    expect(
      ingredients(state, { type: types.INGREDIENT_UPDATE, ingredient: item, data: { name: 'bread flour' } })
    ).toEqual([{ id: 1, name: 'bread flour' }, { id: 2 }]);
  });

  it('leaves other items unchanged on INGREDIENT_UPDATE', () => {
    const item = { id: 1 };
    const other = { id: 2 };
    const result = ingredients([item, other], { type: types.INGREDIENT_UPDATE, ingredient: item, data: { name: 'x' } });
    expect(result[1]).toBe(other);
  });

  it('handles FILTER_INGREDIENTS', () => {
    expect(
      filter({}, { type: types.FILTER_INGREDIENTS, data: { filter: ['gluten-free'] } })
    ).toEqual(['gluten-free']);
  });
});

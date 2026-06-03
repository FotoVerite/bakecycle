import createIngredientStore from '../../../app/assets/javascripts/stores/ingredients';

const baseState = () => ({
  ingredients: [{ id: 1, name: 'flour' }],
  filter: {},
  weightUnitOptions: [{ label: 'lb', value: 'lb' }],
  availableVendors: [{ id: 10, name: 'Mill Co' }],
});

describe('ingredient store', () => {
  it('creates a store without throwing', () => {
    expect(() => createIngredientStore(baseState())).not.toThrow();
  });

  it('preserves all initial state slices', () => {
    const store = createIngredientStore(baseState());
    const state = store.getState();
    expect(state.ingredients).toEqual([{ id: 1, name: 'flour' }]);
    expect(state.weightUnitOptions).toEqual([{ label: 'lb', value: 'lb' }]);
    expect(state.availableVendors).toEqual([{ id: 10, name: 'Mill Co' }]);
  });

  it('does not mutate the input state', () => {
    const initial = baseState();
    createIngredientStore(initial);
    expect(initial.availableVendors).toEqual([{ id: 10, name: 'Mill Co' }]);
  });

  it('exposes a dispatch function', () => {
    const store = createIngredientStore(baseState());
    expect(typeof store.dispatch).toBe('function');
  });
});

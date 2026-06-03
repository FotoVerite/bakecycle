import configureStore from '../../../app/assets/javascripts/stores/order';

const baseState = () => ({
  order: {
    orderItems: [{ productId: 1 }],
    clientId: 5,
    orderType: 'standing',
    errors: {},
  },
  availableClients: [],
  availableRoutes: [],
  availableProducts: [],
});

describe('order store configureStore', () => {
  it('creates a store without throwing', () => {
    expect(() => configureStore(baseState())).not.toThrow();
  });

  it('moves orderItems out of order into top-level state', () => {
    const store = configureStore(baseState());
    const state = store.getState();
    expect(state.order.orderItems).toBeUndefined();
    expect(state.orderItems).toBeDefined();
  });

  it('appends a blank item to orderItems', () => {
    const store = configureStore(baseState());
    expect(store.getState().orderItems).toHaveLength(2);
    expect(store.getState().orderItems[1]).toEqual({});
  });

  it('does not mutate the input state — safe to call twice (React 18 Strict Mode)', () => {
    const initial = baseState();
    configureStore(initial);
    // Second call must not throw even though first call ran
    expect(() => configureStore(initial)).not.toThrow();
    // And the original input must still have orderItems intact
    expect(initial.order.orderItems).toEqual([{ productId: 1 }]);
  });

  it('handles missing orderItems gracefully', () => {
    const state = baseState();
    delete state.order.orderItems;
    const store = configureStore(state);
    expect(store.getState().orderItems).toHaveLength(1);
    expect(store.getState().orderItems[0]).toEqual({});
  });
});

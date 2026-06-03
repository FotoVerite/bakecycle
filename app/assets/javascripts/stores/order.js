import { createStore, compose } from 'redux';
import orderReducer from '../reducers/order';

const configureStore = initialState => {
  // Separate orderItems out of the order object so they get their own reducer slice.
  // Use destructuring instead of mutation — React 18 Strict Mode calls constructors
  // twice in development and the old delete-based approach would corrupt state on retry.
  const { orderItems: existingItems, ...order } = initialState.order;
  const orderItems = [...(existingItems || []), {}];
  return createStore(orderReducer, {
    ...initialState,
    order,
    orderItems,
  }, compose(
    // enable dev tools
    window.devToolsExtension ? window.devToolsExtension() : f => f
  ));
};

export default configureStore;

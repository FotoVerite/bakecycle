import { createStore, compose } from 'redux';
import orderReducer from '../reducers/order';

const configureStore = initialState => {
  // take the order items off of the order so we can separate out the reducers
  const orderItems = initialState.order.orderItems;
  if (orderItems.length === 0) {
    orderItems.push({});
  }
  delete initialState.order.orderItems;
  return createStore(orderReducer, {
    ...initialState,
    orderItems,
  }, compose(
    // enable dev tools
    window.devToolsExtension ? window.devToolsExtension() : f => f
  ));
};

export default configureStore;

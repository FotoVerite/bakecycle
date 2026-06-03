import { configureStore } from '@reduxjs/toolkit';
import orderReducer from '../reducers/order';

const createOrderStore = initialState => {
  const { orderItems: existingItems, ...order } = initialState.order;
  const orderItems = [...(existingItems || []), {}];
  return configureStore({
    reducer: orderReducer,
    preloadedState: { ...initialState, order, orderItems },
  });
};

export default createOrderStore;

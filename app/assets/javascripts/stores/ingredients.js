import { createStore, compose } from 'redux';
import ingredientReducer from '../reducers/ingredients';

const configureStore = initialState => {
  // take the order items off of the order so we can separate out the reducers
  return createStore(ingredientReducer, {
    ...initialState
  }, compose(
    // enable dev tools
    window.devToolsExtension ? window.devToolsExtension() : f => f
  ));
};

export default configureStore;

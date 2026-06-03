import { configureStore } from '@reduxjs/toolkit';
import ingredientReducer from '../reducers/ingredients';

const createIngredientStore = initialState => {
  return configureStore({
    reducer: ingredientReducer,
    preloadedState: { ...initialState },
  });
};

export default createIngredientStore;

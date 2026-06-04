import './shims/react-prop-types'; // Must be first — sets React.PropTypes for legacy CJS packages
import './stimulus_application';

import React from 'react';
import { createRoot } from 'react-dom/client';

import OrderFormProvider from './components/order';
import RecipeForm from './components/recipe-form';

const componentsToRender = window.reactComponents || [];

const bcComponents = window.bcComponents = {
  OrderFormProvider,
  RecipeForm,
};

componentsToRender.forEach(([name, props, node]) => {
  createRoot(node).render(React.createElement(bcComponents[name], props));
});

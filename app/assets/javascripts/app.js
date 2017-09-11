// Polyfills for older browsers

//used by datepicker
import 'classlist-polyfill';

// used by almost everything redux
import 'core-js/fn/object/assign';

// 3rd party library code
import React from 'react';
import ReactDOM from 'react-dom';

// Our classes
import ClientMap from './components/client-map';
import ClientsTable from './components/clients-table';
import FileExportRefresher from './components/file-export-refresher';
import CostingFormProvider from './components/costing';
import OrderFormProvider from './components/order';
import ProductPriceForm from './components/product-price-form';
import RecipeForm from './components/recipe-form';

// React Component Loader
const componentsToRender = window.reactComponents || [];

const bcComponents = window.bcComponents =  {
  ClientMap,
  ClientsTable,
  FileExportRefresher,
  CostingFormProvider,
  OrderFormProvider,
  ProductPriceForm,
  RecipeForm,
};

componentsToRender.forEach(([name, props, node]) => {
  ReactDOM.render(React.createElement(bcComponents[name], props), node);
});

// Polyfills for older browsers
import 'classlist-polyfill';

// 3rd party library code
import React from 'react';
import ReactDOM from 'react-dom';

// Our classes
import OrderForm from './components/order-form';
import ProductPriceForm from './components/product-price-form';
import RecipeForm from './components/recipe-form';
import FileExportRefresher from './components/file-export-refresher';
import ClientsTable from './components/clients-table';
import ClientMap from './components/client-map';

// React Component Loader
const componentsToRender = window.reactComponents || [];

const bcComponents = window.bcComponents =  {
  ProductPriceForm,
  OrderForm,
  RecipeForm,
  FileExportRefresher,
  ClientsTable,
  ClientMap
};

componentsToRender.forEach(([name, props, node]) => {
  ReactDOM.render(React.createElement(bcComponents[name], props), node);
});

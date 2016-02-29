import React from 'react';
import ReactDOM from 'react-dom';

import OrderForm from './components/order-form';
import ProductPriceForm from './components/product-price-form';
import RecipeForm from './components/recipe-form';
import FileExportRefresher from './components/file-export-refresher';
import ClientsTable from './components/clients-table';
import ClientMap from './components/client-map';

let components = {
  ProductPriceForm,
  OrderForm,
  RecipeForm,
  FileExportRefresher,
  ClientsTable,
  ClientMap
};

// Load all react components
let componentsToRender = window.reactComponents || [];
componentsToRender.forEach(([name, props, node]) => {
  ReactDOM.render(React.createElement(components[name], props), node);
});

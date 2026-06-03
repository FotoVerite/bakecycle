import './shims/react-prop-types'; // Must be first — sets React.PropTypes for legacy CJS packages

import React from 'react';
import { createRoot } from 'react-dom/client';

import ClientMap from './components/client-map';
import ClientsTable from './components/clients-table';
import FileExportRefresher from './components/file-export-refresher';
import VendorPricingFormProvider from './components/vendor-pricing';
import OrderFormProvider from './components/order';
import ProductPriceForm from './components/product-price-form';
import RecipeForm from './components/recipe-form';

const componentsToRender = window.reactComponents || [];

const bcComponents = window.bcComponents = {
  ClientMap,
  ClientsTable,
  FileExportRefresher,
  VendorPricingFormProvider,
  OrderFormProvider,
  ProductPriceForm,
  RecipeForm,
};

componentsToRender.forEach(([name, props, node]) => {
  createRoot(node).render(React.createElement(bcComponents[name], props));
});

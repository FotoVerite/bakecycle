import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import createIngredientStore from '../../stores/ingredients';
import VendorPricingForm from './vendor-pricing-form';

class VendorPricingFormProvider extends React.Component {
  constructor(props) {
    super(props);
    this.state = { store: createIngredientStore(props) };
  }

  render() {
    return (
      <Provider store={this.state.store}>
        <VendorPricingForm />
      </Provider>
    );
  }
}

VendorPricingFormProvider.propTypes = {
  ingredients: PropTypes.array.isRequired,
  filter: PropTypes.array.isRequired,
  weightUnitOptions: PropTypes.array.isRequired,
};

export default VendorPricingFormProvider;

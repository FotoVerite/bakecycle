import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
import { Provider } from 'react-redux';
import createIngredientStore from '../../stores/ingredients';
import VendorPricingForm from './vendor-pricing-form';

const VendorPricingFormProvider = createReactClass({
  propTypes: {
    ingredients: PropTypes.array.isRequired,
    filter: PropTypes.array.isRequired,
    weightUnitOptions: PropTypes.array.isRequired
  },

  componentWillMount() {
    const store = createIngredientStore(this.props);
    this.setState({store});
  },

  render() {
    return (
      <Provider store={this.state.store}>
        <VendorPricingForm />
      </Provider>
    );
  }
});

export default VendorPricingFormProvider;

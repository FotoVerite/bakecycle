import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import createIngredientStore from '../../stores/ingredients';
import CostingForm from './costing-form';

class CostingFormProvider extends React.Component {
  constructor(props) {
    super(props);
    this.state = { store: createIngredientStore(props) };
  }

  render() {
    return (
      <Provider store={this.state.store}>
        <CostingForm />
      </Provider>
    );
  }
}

CostingFormProvider.propTypes = {
  ingredients: PropTypes.array.isRequired,
  availableVendors: PropTypes.array.isRequired,
  filter: PropTypes.array.isRequired,
  weightUnitOptions: PropTypes.array.isRequired,
};

export default CostingFormProvider;

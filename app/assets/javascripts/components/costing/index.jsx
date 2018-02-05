import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
import { Provider } from 'react-redux';
import createIngredientStore from '../../stores/ingredients';
import CostingForm from './costing-form';

const CostingFormProvider = createReactClass({
  propTypes: {
    ingredients: PropTypes.array.isRequired,
    availableVendors: PropTypes.array.isRequired,
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
        <CostingForm />
      </Provider>
    );
  }
});

export default CostingFormProvider;

import React, { PropTypes } from 'react';
import { Provider } from 'react-redux';
import createIngredientStore from '../../stores/ingredients';
import CostingForm from './costing-form';

const CostingFormProvider = React.createClass({
  propTypes: {
    ingredients: PropTypes.array.isRequired,
    availableVendors: PropTypes.array.isRequired,
    filter: PropTypes.array.isRequired
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

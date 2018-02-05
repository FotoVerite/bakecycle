import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
import { Provider } from 'react-redux';
import createOrderStore from '../../stores/order';
import OrderForm from './order-form';

const OrderFormProvider = createReactClass({
  propTypes: {
    order: PropTypes.object.isRequired,
    availableClients: PropTypes.array.isRequired,
    availableRoutes: PropTypes.array.isRequired,
    availableProducts: PropTypes.array.isRequired,
  },

  componentWillMount() {
    const store = createOrderStore(this.props);
    this.setState({store});
  },

  render() {
    return (
      <Provider store={this.state.store}>
        <OrderForm />
      </Provider>
    );
  }
});

export default OrderFormProvider;

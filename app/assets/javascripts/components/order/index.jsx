import React from 'react';
import PropTypes from 'prop-types';
import { Provider } from 'react-redux';
import createOrderStore from '../../stores/order';
import OrderForm from './order-form';

class OrderFormProvider extends React.Component {
  constructor(props) {
    super(props);
    this.state = { store: createOrderStore(props) };
  }

  render() {
    return (
      <Provider store={this.state.store}>
        <OrderForm />
      </Provider>
    );
  }
}

OrderFormProvider.propTypes = {
  order: PropTypes.object.isRequired,
  availableClients: PropTypes.array.isRequired,
  availableRoutes: PropTypes.array.isRequired,
  availableProducts: PropTypes.array.isRequired,
};

export default OrderFormProvider;

import React, { PropTypes } from 'react';
import { Provider } from 'react-redux';
import createOrderStore from '../../stores/order';
import OrderForm from './order-form';

const OrderFormProvider = React.createClass({
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

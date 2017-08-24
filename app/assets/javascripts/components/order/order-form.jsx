import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import * as orderActions from '../../actions/order';
import OrderItemsForm from './order-items-form';
import includes from 'lodash.includes';
import {
  BCDate,
  BCRadio,
  BCSelect,
  BCTextarea,
  BCCheckbox,
} from '../bakecycle-inputs';

const OrderForm = React.createClass({
  propTypes: {
    order: PropTypes.object.isRequired,
    availableClients: PropTypes.array.isRequired,
    availableRoutes: PropTypes.array.isRequired,
    updateOrder: PropTypes.func.isRequired,
    validateOrderStartDate: PropTypes.func.isRequired
  },

  clientOptions() {
    return this.props.availableClients.map((client) => {
      return <option key={`client-${client.id}`} value={client.id}>{client.name}</option>;
    });
  },

  routesOptions() {
    return this.props.availableRoutes.map((route) => {
      return <option key={`route-${route.id}`} value={route.id}>{route.name}</option>;
    });
  },

  errorFor(field) {
    const { errors } = this.props.order;
    return errors[field] && errors[field][0];
  },

  showClients() {
    const { order, updateOrder } = this.props;
    if (order.id) {
      return;
    }
    return (
      <div className="row">
        <div className="small-12 medium-4 columns">
          <BCSelect
            value={order.clientId}
            field="clientId"
            options={this.clientOptions()}
            name="order[client_id]"
            label="Client"
            required
            error={this.errorFor('client_id')}
            onChange={updateOrder}
          />
        </div>
      </div>
    );
  },

  showLeadDays() {
    const { order } = this.props;
    return (
      <div className="row">
        <div className="small-12 medium-6 columns">
          <p><strong>Order Lead Days: {order.totalLeadDays}</strong></p>
        </div>
      </div>
    );
  },

  componentDidUpdate (prevProps) {
    const prevOrder = prevProps.order;
    const order = this.props.order;
    if (
        prevOrder.totalLeadDays !== order.totalLeadDays ||
        prevOrder.startDate !== order.startDate ||
        prevOrder.endDate !== order.endDate
      )
    {
      this.props.validateOrderStartDate(order);
    }
    if(order.errors.start_date && order.errors.start_date.length){
      $('input[type="submit"]').addClass('warning');
      $('#kickoff-warning').removeClass('hide');
    } else {
      $('input[type="submit"]').removeClass('warning');
      $('#kickoff-warning').addClass('hide');
    }
  },

  render() {
    const { order, updateOrder } = this.props;
    let endDate;
    if (order.orderType !== 'temporary') {
      endDate = (
        <div className="small-12 medium-4 columns">
          <BCDate
            value={order.endDate}
            field="endDate"
            name="order[end_date]"
            label="End Date"
            placeholder="YYYY-MM-DD"
            error={this.errorFor('end_date')}
            onChange={updateOrder}
          />
        </div>
      );
    }
    return (<div>
      <fieldset>
        <legend>Order Information</legend>
          {this.showClients()}
        <div className="row">
          <div className="small-12 columns end">
            <BCRadio
              value={order.orderType}
              field="orderType"
              options={[['Standing', 'standing'], ['Temporary', 'temporary']]}
              name="order[order_type]"
              label="Order Type"
              required
              error={this.errorFor('order_type')}
              onChange={updateOrder}
            />
            <p className="help-text-order-type">
              Standing orders repeat every week, temporary orders override standing orders for a specific date
            </p>
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <BCCheckbox
              value={order.alert}
              field="alert"
              name="order[alert]"
              label="Alert"
              onChange={updateOrder}
            />
          </div>
        </div>
        <div className="row">
          <div className="small-12 medium-4 columns">
            <BCDate
              value={order.startDate}
              field="startDate"
              name="order[start_date]"
              label="Start Date"
              placeholder="YYYY-MM-DD"
              required
              error={this.errorFor('start_date')}
              onChange={updateOrder}
            />
          </div>
          {endDate}
          <div className="small-12 medium-4 columns end">
            <BCSelect
              value={order.routeId}
              field="routeId"
              options={this.routesOptions()}
              name="order[route_id]"
              label="Route"
              required
              error={this.errorFor('route_id')}
              onChange={updateOrder}
            />
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <BCTextarea
              value={order.note}
              field="note"
              name="order[note]"
              label="Special Notes"
              onChange={updateOrder}
            />
          </div>
        </div>
        {this.showLeadDays()}
      </fieldset>
      <OrderItemsForm />
    </div>);
  }
});

const calculateTotalLeadDays = function(availableProducts, orderItems) {
  const orderItemsIds = orderItems.map((orderItem) => {
    return orderItem.productId;
  });
  const totalLeadDays = availableProducts.filter(a => includes(orderItemsIds, a.id)).map(p => p.totalLeadDays);
  return totalLeadDays.length === 0 ? 0 : Math.max(...totalLeadDays);
};

const stateToProps = function(state) {
  const totalLeadDays = {
    totalLeadDays: calculateTotalLeadDays(state.availableProducts, state.orderItems)
  };
  return {order:  Object.assign({}, state.order, totalLeadDays),
  availableClients: state.availableClients,
  availableRoutes: state.availableRoutes,
  };
};

export default connect(stateToProps, orderActions)(OrderForm);

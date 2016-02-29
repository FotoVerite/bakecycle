import React from 'react';
import OrderItemsForm from './order-items-form';
import { Order, OrderItems } from '../stores/order-store';
import {BCDate, BCTextarea, BCSelect, BCRadio } from './bakecycle-backbone-inputs';

let OrderForm = React.createClass({
  getInitialState() {
    let order = new Order(this.props.order);
    let items = new OrderItems(this.props.order.orderItems);
    items.addBlankForm();
    items.on('change sort remove add', () => this.setState({items}));
    order.on('change', () => this.setState({order}));
    return { items, order };
  },

  willReceiveProps(nextProps) {
    this.state.items.set(nextProps.orderItems);
    this.state.items.addBlankForm();
    this.state.order.set(nextProps);
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
    let errors = this.state.order.get('errors');
    return errors[field] && errors[field][0];
  },

  showClients() {
    let order = this.state.order;
    if (order.id) {
      return;
    }
    return (
      <div className="row">
        <div className="small-12 medium-4 columns">
          <BCSelect
            model={order}
            field='clientId'
            options={this.clientOptions()}
            name='order[client_id]'
            label='Client'
            required
            error={this.errorFor('client_id')}
          />
        </div>
      </div>
    );
  },

  showLeadDays() {
    let order = this.state.order;
    if (!order.id) {
      return;
    }
    return (
      <div className="row">
        <div className="small-12 medium-6 columns">
          <p><strong>Order Lead Days: {order.get('totalLeadDays')}</strong></p>
        </div>
      </div>
    );
  },

  render() {
    let order = this.state.order;

    let endDate;
    if (order.get('orderType') !== 'temporary') {
      endDate = (
        <div className="small-12 medium-4 columns">
          <BCDate
            model={order}
            field='endDate'
            name='order[end_date]'
            label='End Date'
            placeholder="YYYY-MM-DD"
            error={this.errorFor('end_date')}
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
              model={order}
              field='orderType'
              options={[['Standing', 'standing'], ['Temporary', 'temporary']]}
              name='order[order_type]'
              label='Order Type'
              required
              error={this.errorFor('order_type')}
            />
            <p className="help-text-order-type">
              Standing orders repeat every week, temporary orders override standing orders for a specific date
            </p>
          </div>
        </div>
        <div className="row">
          <div className="small-12 medium-4 columns">
            <BCDate
              model={order}
              field='startDate'
              name='order[start_date]'
              label='Start Date'
              placeholder="YYYY-MM-DD"
              required
              error={this.errorFor('start_date')}
            />
          </div>
          {endDate}
          <div className="small-12 medium-4 columns end">
            <BCSelect
              model={order}
              field='routeId'
              options={this.routesOptions()}
              name='order[route_id]'
              label='Route'
              required
              error={this.errorFor('route_id')}
            />
          </div>
        </div>
        <div className="row">
          <div className="small-12 columns">
            <BCTextarea
              model={order}
              field="note"
              name="order[note]"
              label="Special Notes"
            />
          </div>
        </div>
        {this.showLeadDays()}
      </fieldset>
      <OrderItemsForm
        model={this.state.order}
        availableProducts={this.props.availableProducts}
        nestedItems={this.state.items}
        temporaryOrder={order.get('orderType') === 'temporary'}
        startDate={order.get('startDate')}
      />
    </div>);
  }
});

export default OrderForm;


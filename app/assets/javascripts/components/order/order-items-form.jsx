import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import differenceBy from 'lodash.differenceby';
import OrderItemFields from './order-item-fields';
import * as orderActions from '../../actions/order';

const OrderItemsForm = ({
    addOrderItem,
    availableProducts,
    orderItems,
    orderType,
    startDate,
    toggleDestroy,
    updateOrderItem,
  }) => {

  const usedProducts = orderItems.map(item => item.productId);

  const fields = orderItems.map((model, index) => {
    const removeProductIds = usedProducts.filter(p => p !== model.productId);
    const productsForItem = differenceBy(availableProducts, removeProductIds, p => p && p.id || p);
    return (<OrderItemFields
      addOrderItem={addOrderItem}
      availableProducts={productsForItem}
      key={`orderitem-${index}`}
      model={model}
      onChange={updateOrderItem.bind(null, model)}
      startDate={startDate}
      temporaryOrder={orderType === 'temporary'}
      toggleDestroy={toggleDestroy.bind(null, model)}
    />);
  });

  return (
    <fieldset>
      <legend>Products</legend>
      <div className="row show-for-large-up">
        <div className="small-12 columns">
          <div className="order-item-product-selection">
            <label>Product</label>
          </div>
          <div className="order-item-price-per-qt">
            <label>Price</label>
          </div>
          <div className="order-item-price-total">
            <label>Total</label>
          </div>
          <div className="order-item-day-input">
            <label>Mon</label>
          </div>
          <div className="order-item-day-input">
            <label>Tue</label>
          </div>
          <div className="order-item-day-input">
            <label>Wed</label>
          </div>
          <div className="order-item-day-input">
            <label>Thur</label>
          </div>
          <div className="order-item-day-input">
            <label>Fri</label>
          </div>
          <div className="order-item-day-input">
            <label>Sat</label>
          </div>
          <div className="order-item-day-input end">
            <label>Sun</label>
          </div>
        </div>
      </div>
      {fields}
    </fieldset>
  );
};

OrderItemsForm.propTypes = {
  addOrderItem: PropTypes.func.isRequired,
  availableProducts: PropTypes.array.isRequired,
  orderItems: PropTypes.array.isRequired,
  orderType: PropTypes.string.isRequired,
  toggleDestroy: PropTypes.func.isRequired,
  updateOrderItem: PropTypes.func.isRequired,
  startDate: PropTypes.string,
};

const stateToProps = state => {
  const {availableProducts, orderItems, order} = state;
  const {orderType, startDate} = order;
  return {
    availableProducts,
    orderItems,
    orderType,
    startDate,
  };
};

export default connect(stateToProps, orderActions)(OrderItemsForm);

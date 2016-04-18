import React, { PropTypes } from 'react';
import OrderItemFields from './order-item-fields';

export default function OrderItemsForm({ temporaryOrder, startDate, nestedItems, availableProducts }) {
  const fields = nestedItems.map((model) => {
    return (<OrderItemFields
      key={`orderitem-${model.cid}`}
      availableProducts={availableProducts}
      model={model}
      temporaryOrder={temporaryOrder}
      startDate={startDate}
    />);
  });

  const addItem = (event) => {
    event.preventDefault();
    nestedItems.add({});
  };

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
      <a onClick={addItem} className="button" >Add Product</a>
    </fieldset>
  );
}

OrderItemsForm.propTypes = {
  nestedItems: PropTypes.object.isRequired,
  temporaryOrder: PropTypes.bool.isRequired,
  startDate: PropTypes.string.isRequired,
  availableProducts: PropTypes.array.isRequired,
};

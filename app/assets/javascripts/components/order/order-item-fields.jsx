import React, { PropTypes } from 'react';
import uniqueId from 'lodash.uniqueid';
import { BCInput, BCSelect } from '../bakecycle-inputs';

export default function OrderItemFields({
    model,
    availableProducts,
    temporaryOrder,
    startDate,
    onChange,
    addOrderItem,
    toggleDestroy,
  }) {

  function onDestroy(e) {
    e.preventDefault();
    toggleDestroy();
  }

  function checkDisabled(dayNum) {
    if (!temporaryOrder || !startDate) {
      return false;
    }

    var parsedDate = new Date(startDate);
    return parsedDate.getUTCDay() !== dayNum;
  }

  function renderDays() {
    var days = [
      ['Mon', 'monday', 1],
      ['Tue', 'tuesday', 2],
      ['Wed', 'wednesday', 3],
      ['Thur', 'thursday', 4],
      ['Fri', 'friday', 5],
      ['Sat', 'saturday', 6],
      ['Sun', 'sunday', 0],
    ];

    return days.map((day) => {
      const id = 'foo';
      return (
        <div className="order-item-day-input" key={`${id}-${day[1]}`}>
          <BCInput
            value={model[day[1]]}
            field={day[1]}
            name={`${namePrefix}[${day[1]}]`}
            label={day[0]}
            labelClass="hide-for-large-up"
            disabled={checkDisabled(day[2])}
            autoComplete="off"
            onChange={onChange}
          />
        </div>
      );
    });
  }

  function getError(field) {
    var errors = model.errors || {};
    if (Array.isArray(errors[field])) {
      return errors[field][0];
    }
    return errors[field];
  }

  function addButton(e) {
    e.preventDefault();
    addOrderItem();
  }

  var {
    id,
    destroy,
    totalLeadDays,
    productPriceAndQuantity,
    totalQuantityPriceCurrency
  } = model;

  var namePrefix = `order[order_items_attributes][${uniqueId()}]`;
  var disabledClass = destroy ? 'disabled' : '';

  if (destroy) {
    var destroyField = <input type="hidden" name={`${namePrefix}[_destroy]`} value="true" />;
  }

  if (id) {
    var idField = <input type="hidden" name={`${namePrefix}[id]`} value={id} />;
  }

  var productOptions = availableProducts.map((product) => {
    return <option key={`product-${product.id}`} value={product.id}>{product.name}</option>;
  });

  return (
    <div className={`fields ${disabledClass}`} >
      {idField}
      {destroyField}
      <div className="row">
        <div className="small-12 columns">
          <div className="order-item-product-selection">
            <BCSelect
              value={model.productId}
              field="productId"
              name={`${namePrefix}[product_id]`}
              options={productOptions}
              error={getError('product_id')}
              disabled={destroy}
              label="Product"
              labelClass="hide-for-large-up"
              includeBlank="--None--"
              required
              onChange={onChange}
            />
          </div>

          <div className="order-item-price-per-qt" title={`Lead Days ${totalLeadDays}`}>
            <label className="hide-for-large-up">Price</label>
            <input disabled="true" type="text" value={productPriceAndQuantity} />
          </div>

          <div className="order-item-price-total">
            <label className="hide-for-large-up">Total</label>
            <input disabled="true" type="text" value={totalQuantityPriceCurrency} />
          </div>

          {renderDays()}

          <div className="order-item-action-button">
            <a onClick={onDestroy} className="remove_order_item">
              {destroy ?
                <span className="secondary radius label">Undo</span>
                :
                <span className="alert radius label">X</span>
               }
            </a>
          </div>
          <div className="order-item-action-button">
            <a onClick={addButton}>
              <span className="success radius label">Add</span>
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}

OrderItemFields.propTypes = {
  addOrderItem: PropTypes.func.isRequired,
  availableProducts: PropTypes.array.isRequired,
  model: PropTypes.object.isRequired,
  onChange: PropTypes.func.isRequired,
  temporaryOrder: PropTypes.bool.isRequired,
  toggleDestroy: PropTypes.func.isRequired,
  startDate: PropTypes.string,
};

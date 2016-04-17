import React from 'react';
import { BCInput, BCSelect } from './bakecycle-backbone-inputs';

module.exports = React.createClass({
  toggleDestroy(e) {
    e.preventDefault();
    var model = this.props.model;
    var destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  },

  namePrefix() {
    var {model} = this.props;
    return `order[order_items_attributes][${model.getNumericCID()}]`;
  },

  checkDisabled(dayNum) {
    var {startDate, temporaryOrder} = this.props;
    if (!temporaryOrder || !startDate) {
      return false;
    }

    var parsedDate = new Date(startDate);
    return parsedDate.getUTCDay() !== dayNum;
  },

  renderDays() {
    var {model} = this.props;
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
      return (
        <div className="order-item-day-input" key={`${model.cid}-${day[1]}`}>
          <BCInput
            model={this.props.model}
            field={day[1]}
            name={`${this.namePrefix()}[${day[1]}]`}
            label={day[0]}
            labelClass="hide-for-large-up"
            disabled={this.checkDisabled(day[2])}
            autoComplete="off"
          />
        </div>
      );
    });
  },

  render() {
    var {
      availableProducts,
      model,
    } = this.props;

    var {
      id,
      destroy,
      totalLeadDays,
      productPriceAndQuantity,
      totalQuantityPriceCurrency
    } = model.toJSON();

    var namePrefix = this.namePrefix();
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
                model={model}
                field="productId"
                name={`${namePrefix}[product_id]`}
                options={productOptions}
                error={model.getError('product_id')}
                disabled={destroy}
                label="Product"
                labelClass="hide-for-large-up"
                includeBlank="--None--"
                required
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

            {this.renderDays()}

            <div className="order-item-delete-button">
              <a onClick={this.toggleDestroy} className="remove_order_item" >
                {destroy ? 'Undo' : 'X'}
              </a>

            </div>
          </div>
        </div>
      </div>
    );
  },
});

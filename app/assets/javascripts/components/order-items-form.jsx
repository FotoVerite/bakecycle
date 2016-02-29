var React = require('react');
var OrderItemFields = require('./order-item-fields');

var OrderItemsForm = React.createClass({
  addItem: function(event) {
    event.preventDefault();
    this.props.nestedItems.add({});
  },

  render() {
    var {
      temporaryOrder,
      startDate,
      nestedItems
    } = this.props;

    var fields = nestedItems.map((model) => {
      return (<OrderItemFields
        key={`orderitem-${model.cid}`}
        availableProducts={this.props.availableProducts}
        model={model}
        temporaryOrder={temporaryOrder}
        startDate={startDate}
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
        <a onClick={this.addItem} className="button" >Add Product</a>
      </fieldset>
    );
  }
});

export default OrderItemsForm;

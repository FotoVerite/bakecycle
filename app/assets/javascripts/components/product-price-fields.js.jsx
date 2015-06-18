var React = require('react');

module.exports = React.createClass({
  getDefaultProps: function() {
    return {
      errors: {},
      price: '',
      quantity: ''
    };
  },

  errorFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  errorClassFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return 'error';
  },

  toggleDestroy: function() {
    this.props.store.toggleDestroy(this.props.index);
  },

  updatePrice: function(event) {
    this.props.store.updateField(this.props.index, 'price', event.target.value);
  },

  updateQuantity: function(event) {
    this.props.store.updateField(this.props.index, 'quantity', event.target.value);
  },

  render: function() {
    var {price, quantity, id, index, destroy} = this.props;
    var namePrefix = `product[price_variants_attributes][${index}]`;
    var backgroundStyle = destroy ? {backgroundColor: 'lightgrey'} : {};

    var undoButton = <a onClick={this.toggleDestroy} className="button alert postfix" >Undo</a>;
    var removeButton = <a onClick={this.toggleDestroy} className="test-remove-button button alert postfix" >X</a>;

    return (<div className="fields">
      <input type="hidden" name={`${namePrefix}[id]`} value={id} />
      <input type="hidden" name={`${namePrefix}[_destroy]`} value={destroy} />
      <div className="row collapse">
        <div className="small-12 medium-4 columns">
          <label className="string required hide-for-medium-up">
            <abbr title="required">*</abbr>Price
          </label>
          <input
            className={`price_input ${this.errorClassFor('price')}`}
            disabled={destroy}
            name={`${namePrefix}[price]`}
            onChange={this.updatePrice}
            placeholder="0.00"
            style={backgroundStyle}
            type="text"
            value={price} />
          {this.errorFor('price')}
        </div>
        <div className="small-12 medium-4 columns">
          <label className="string required hide-for-medium-up">
            <abbr title="required">*</abbr>Quantity
          </label>
          <input
            className={`quantity_input ${this.errorClassFor('quantity')}`}
            disabled={destroy}
            name={`${namePrefix}[quantity]`}
            onChange={this.updateQuantity}
            placeholder="0"
            style={backgroundStyle}
            type="text"
            value={quantity} />
          {this.errorFor('quantity')}
        </div>
        <div className="small-12 medium-4 columns">
          {destroy ? undoButton : removeButton}
        </div>
      </div>
    </div>);
  },
});

var React = require('react');
var ArrayStore = require('../stores/array-store');
var PriceFields = require('./product-price-fields');

module.exports = React.createClass({
  getInitialState: function() {
    var prices = new ArrayStore(this.props.priceVariants);
    this.addBlankForm(prices);
    var updateState = () => {
      this.setState({prices: prices});
    };
    prices.onChange(updateState);
    return {prices: prices};
  },

  willReceiveProps: function(nextProps) {
    var prices = this.state.prices.updateAll(nextProps.priceVariants);
    this.addBlankForm(prices);
  },

  addBlankForm: function(prices) {
    if (!prices.length()) {
      return prices.add({});
    }
    if (prices.get(prices.length() - 1).id) {
      prices.add({});
    }
  },

  addPrice: function(event) {
    event.preventDefault();
    this.state.prices.add({});
  },

  render: function() {
    var prices = this.state.prices;
    var fields = prices.map((price, index) => {
      return <PriceFields
        {...price}
        index={index}
        store={prices} />;
    });

    return (<div>
      <fieldset>
        <legend>Prices</legend>
        <div className="row collapse">
          <div className="small-12 medium-4 columns">
            <label className="string required hide-for-small-down">
              <abbr title="required">*</abbr>Price
            </label>
          </div>
          <div className="small-12 medium-4 columns end">
            <label className="string required hide-for-small-down">
              <abbr title="required">*</abbr>Quantity
            </label>
          </div>
        </div>
        {fields}
        <a href='#' onClick={this.addPrice} className="button" >Add New Price</a>
      </fieldset>
    </div>);
  }
});

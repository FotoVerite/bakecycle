var React = require('react');
var PriceField = require('./price-field');
var PriceStore = require('./../stores/price-store');

module.exports = React.createClass({
  getInitialState: function() {
    var prices = new PriceStore(this.props.priceVariants);
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
      return <PriceField
        {...price}
        index={index}
        prices={prices} />;
    });

    return (<div>
      <fieldset>
        <legend>Prices</legend>
        <div className="row collapse">
          <div className="small-12 medium-4 columns">
            <div className="input string required">
              <label className="string required">
                <abbr title="required">*</abbr>Price
              </label>
            </div>
          </div>
          <div className="small-12 medium-4 columns end">
            <div className="input string required">
              <label className="string required">
                <abbr title="required">*</abbr>Quantity
              </label>
            </div>
          </div>
        </div>
        {fields}
        <a href='#' onClick={this.addPrice} className="button" >Add New Price</a>
      </fieldset>
    </div>);
  }
});

var React = require('react');
var PricesStore = require('../stores/prices-store');
var PriceFields = require('./product-price-fields');

module.exports = React.createClass({
  getInitialState: function() {
    var prices = new PricesStore(this.props.priceVariants);
    prices.addBlankForm();
    prices.on('change sort remove add', () => this.setState({ prices }));
    return { prices };
  },

  willReceiveProps: function(nextProps) {
    var prices = this.state.prices.set(nextProps.priceVariants);
    prices.addBlankForm();
  },

  addPrice: function(event) {
    event.preventDefault();
    this.state.prices.add({});
  },

  render: function() {
    var prices = this.state.prices;
    var clients = this.props.clients;
    var fields = prices.map((priceVariant) => {
      return <PriceFields key={priceVariant.cid} model={priceVariant} clients={clients} />;
    });

    return (<div>
      <fieldset>
        <legend>Prices</legend>
        <div className="row collapse">
          <div className="small-12 medium-5 columns">
            <label className="string required hide-for-small-down">
              Client
            </label>
          </div>
          <div className="small-12 medium-3 columns end">
            <label className="string required hide-for-small-down">
              Quantity <abbr title="required">*</abbr>
            </label>
          </div>
          <div className="small-12 medium-3 columns end">
            <label className="string required hide-for-small-down">
              Price <abbr title="required">*</abbr>
            </label>
          </div>
        </div>
        {fields}
        <a href='#' onClick={this.addPrice} className="button" >Add New Price</a>
      </fieldset>
    </div>);
  }
});

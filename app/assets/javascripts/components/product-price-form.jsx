import React from 'react';
import PricesStore from '../stores/prices-store';
import PriceFields from './product-price-fields';

let ProductPriceForm = React.createClass({
  getInitialState: function() {
    let prices = new PricesStore(this.props.priceVariants);
    prices.addBlankForm();
    prices.on('change sort remove add', () => this.setState({ prices }));
    return { prices };
  },

  willReceiveProps: function(nextProps) {
    let prices = this.state.prices.set(nextProps.priceletiants);
    prices.addBlankForm();
  },

  addPrice: function(event) {
    event.preventDefault();
    this.state.prices.add({});
  },

  render: function() {
    let prices = this.state.prices;
    let clients = this.props.clients;
    let fields = prices.map((priceVariant) => {
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

export default ProductPriceForm;

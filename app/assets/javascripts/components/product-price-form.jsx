import React, { PropTypes } from 'react';
import PricesStore from '../stores/prices-store';
import PriceFields from './product-price-fields';

const ProductPriceForm = React.createClass({
  propTypes: {
    product: PropTypes.object.isRequired,
    clients: PropTypes.array.isRequired,
  },

  getInitialState() {
    const prices = new PricesStore(this.props.product.priceVariants);
    prices.addBlankForm();
    prices.on('change sort remove add', () => this.setState({ prices }));
    return { prices };
  },

  willReceiveProps(nextProps) {
    const prices = this.state.prices.set(nextProps.priceletiants);
    prices.addBlankForm();
  },

  addPrice(event) {
    event.preventDefault();
    this.state.prices.add({});
  },

  render() {
    const { prices } = this.state;
    const { clients } = this.props;
    const fields = prices.map((priceVariant) => {
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
        <a href="#" onClick={this.addPrice} className="button" >Add New Price</a>
      </fieldset>
    </div>);
  }
});

export default ProductPriceForm;

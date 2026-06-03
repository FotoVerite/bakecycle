import React from 'react';
import PropTypes from 'prop-types';
import PriceFields from './product-price-fields';

function getError(price, field) {
  const errors = price.errors || {};
  const val = errors[field];
  return Array.isArray(val) ? val[0] : val;
}

class ProductPriceForm extends React.Component {
  constructor(props) {
    super(props);
    let keyCounter = 0;
    let prices = props.product.priceVariants.map(data => ({ ...data, _key: keyCounter++ }));
    if (prices.length === 0 || prices[prices.length - 1].id) {
      prices = [...prices, { _key: keyCounter++ }];
    }
    this._keyCounter = keyCounter;
    this.state = { prices };
    this.addPrice = this.addPrice.bind(this);
    this.updatePrice = this.updatePrice.bind(this);
    this.toggleDestroy = this.toggleDestroy.bind(this);
  }

  addPrice(event) {
    event.preventDefault();
    const newPrice = { _key: this._keyCounter++ };
    this.setState(state => ({ prices: [...state.prices, newPrice] }));
  }

  updatePrice(price, data) {
    this.setState(state => ({
      prices: state.prices.map(p => p === price ? { ...p, ...data } : p),
    }));
  }

  toggleDestroy(price) {
    if (!price.id) {
      this.setState(state => ({ prices: state.prices.filter(p => p !== price) }));
    } else {
      this.updatePrice(price, { destroy: !price.destroy });
    }
  }

  render() {
    const { prices } = this.state;
    const { clients } = this.props;
    const fields = prices.map((price) => (
      <PriceFields
        key={price._key}
        model={price}
        clients={clients}
        onChange={(data) => this.updatePrice(price, data)}
        onToggleDestroy={() => this.toggleDestroy(price)}
        getError={(field) => getError(price, field)}
      />
    ));
    return (
      <div>
        <fieldset>
          <legend>Prices</legend>
          <div className="row collapse">
            <div className="small-12 medium-5 columns">
              <label className="string required hide-for-small-down">Client</label>
            </div>
            <div className="small-12 medium-3 columns end">
              <label className="string required hide-for-small-down">Quantity <abbr title="required">*</abbr></label>
            </div>
            <div className="small-12 medium-3 columns end">
              <label className="string required hide-for-small-down">Price <abbr title="required">*</abbr></label>
            </div>
          </div>
          {fields}
          <a href="#" onClick={this.addPrice} className="button">Add New Price</a>
        </fieldset>
      </div>
    );
  }
}

ProductPriceForm.propTypes = {
  product: PropTypes.object.isRequired,
  clients: PropTypes.array.isRequired,
};

export default ProductPriceForm;

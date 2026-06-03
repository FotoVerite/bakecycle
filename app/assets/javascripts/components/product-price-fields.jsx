import React from 'react';
import PropTypes from 'prop-types';
import { BCInput, BCSelect } from './bakecycle-inputs';

class ProductPriceField extends React.Component {
  render() {
    const { model, clients, onChange, onToggleDestroy, getError } = this.props;
    const { id, destroy, clientId, quantity, price } = model;
    const namePrefix = `product[price_variants_attributes][${model._key}]`;
    const disabledClass = destroy ? 'disabled' : '';

    const clientOptions = clients.map((client) => (
      <option key={`client-${model._key}-${client.id}`} value={client.id}>{client.name}</option>
    ));
    clientOptions.unshift(<option key={`client-${model._key}-all`} value="">All</option>);

    const undoButton = <a onClick={onToggleDestroy} className="button alert postfix">Undo</a>;
    const removeButton = <a onClick={onToggleDestroy} className="test-remove-button button alert postfix">X</a>;

    return (
      <div className={`fields ${disabledClass}`}>
        {id ? <input type="hidden" name={`${namePrefix}[id]`} value={id} /> : null}
        {destroy ? <input type="hidden" name={`${namePrefix}[_destroy]`} value="true" /> : null}
        <div className="row collapse">
          <div className="small-12 medium-5 columns">
            <label className="string required hide-for-medium-up">Client</label>
            <BCSelect value={clientId} field="clientId" options={clientOptions} name={`${namePrefix}[client_id]`} type="number" error={getError('client_id')} disabled={destroy} onChange={onChange} />
          </div>
          <div className="small-12 medium-3 columns">
            <label className="string required hide-for-medium-up">Minimum Quantity <abbr title="required">*</abbr></label>
            <BCInput value={quantity} field="quantity" name={`${namePrefix}[quantity]`} type="number" error={getError('quantity')} placeholder="0" disabled={destroy} required onChange={onChange} />
          </div>
          <div className="small-12 medium-3 columns">
            <label className="string required hide-for-medium-up">Price <abbr title="required">*</abbr></label>
            <BCInput value={price} field="price" name={`${namePrefix}[price]`} type="number" error={getError('price')} placeholder="0.00" disabled={destroy} required onChange={onChange} />
          </div>
          <div className="small-12 medium-1 columns end">
            {destroy ? undoButton : removeButton}
          </div>
        </div>
      </div>
    );
  }
}

ProductPriceField.propTypes = {
  model: PropTypes.object.isRequired,
  clients: PropTypes.array.isRequired,
  onChange: PropTypes.func.isRequired,
  onToggleDestroy: PropTypes.func.isRequired,
  getError: PropTypes.func.isRequired,
};

export default ProductPriceField;

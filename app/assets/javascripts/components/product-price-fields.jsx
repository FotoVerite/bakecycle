import React, { PropTypes } from 'react';
import { BCInput, BCSelect } from './bakecycle-backbone-inputs';

const ProductPriceField = React.createClass({
  propTypes: {
    errors: PropTypes.object.isRequired,
    model: PropTypes.object.isRequired,
    clients: PropTypes.array.isRequired
  },

  errorFor(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  toggleDestroy() {
    const model = this.props.model;
    const destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  },

  render() {
    const model = this.props.model;
    const { id, destroy } = model.toJSON();
    const clients = this.props.clients.map((client) => {
      return <option key={`client-${model.getNumericCID()}-${client.id}`} value={client.id}>{client.name}</option>;
    });
    clients.unshift(<option key={`client-${model.getNumericCID()}-all`} value="">All</option>);
    const namePrefix = `product[price_variants_attributes][${model.getNumericCID()}]`;
    const disabledClass = destroy ? 'disabled' : '';

    const undoButton = <a onClick={this.toggleDestroy} className="button alert postfix" >Undo</a>;
    const removeButton = <a onClick={this.toggleDestroy} className="test-remove-button button alert postfix" >X</a>;

    let idField;
    if (id) {
      idField = <input type="hidden" name={`${namePrefix}[id]`} value={id} />;
    }

    let destroyField;
    if (destroy) {
      destroyField = <input type="hidden" name={`${namePrefix}[_destroy]`} value="true" />;
    }

    return (<div className={`fields ${disabledClass}`}>
      {idField}
      {destroyField}
      <div className="row collapse">
        <div className="small-12 medium-5 columns">
          <label className="string required hide-for-medium-up">
            Client
          </label>
          <BCSelect
            model={model}
            field="clientId"
            options={clients}
            name={`${namePrefix}[client_id]`}
            type="number"
            error={model.getError('client_id')}
            disabled={destroy}
          />
        </div>
        <div className="small-12 medium-3 columns">
          <label className="string required hide-for-medium-up">
            Minimum Quantity <abbr title="required">*</abbr>
          </label>
          <BCInput
            model={model}
            field="quantity"
            name={`${namePrefix}[quantity]`}
            type="number"
            error={model.getError('quantity')}
            placeholder="0"
            disabled={destroy}
            required
          />
        </div>
        <div className="small-12 medium-3 columns">
          <label className="string required hide-for-medium-up">
            Price <abbr title="required">*</abbr>
          </label>
          <BCInput
            model={model}
            field="price"
            name={`${namePrefix}[price]`}
            type="number"
            error={model.getError('price')}
            placeholder="0.00"
            disabled={destroy}
            required
          />
        </div>
        <div className="small-12 medium-1 columns end">
          {destroy ? undoButton : removeButton}
        </div>
      </div>
    </div>);
  }
});

export default ProductPriceField;

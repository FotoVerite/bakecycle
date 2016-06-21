import React, { PropTypes } from 'react';
import { BCInput, BCSelect } from './bakecycle-inputs';

const ProductPriceField = React.createClass({
  propTypes: {
    model: PropTypes.object.isRequired,
    clients: PropTypes.array.isRequired
  },

  toggleDestroy() {
    const model = this.props.model;
    const destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  },

  render() {
    const model = this.props.model;
    const onChange = model.set.bind(model);
    const data = model.toJSON();
    const { id, destroy } = data;
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
            value={data.clientId}
            field="clientId"
            options={clients}
            name={`${namePrefix}[client_id]`}
            type="number"
            error={model.getError('client_id')}
            disabled={destroy}
            onChange={onChange}
          />
        </div>
        <div className="small-12 medium-3 columns">
          <label className="string required hide-for-medium-up">
            Minimum Quantity <abbr title="required">*</abbr>
          </label>
          <BCInput
            value={data.quantity}
            field="quantity"
            name={`${namePrefix}[quantity]`}
            type="number"
            error={model.getError('quantity')}
            placeholder="0"
            disabled={destroy}
            required
            onChange={onChange}
          />
        </div>
        <div className="small-12 medium-3 columns">
          <label className="string required hide-for-medium-up">
            Price <abbr title="required">*</abbr>
          </label>
          <BCInput
            value={data.price}
            field="price"
            name={`${namePrefix}[price]`}
            type="number"
            error={model.getError('price')}
            placeholder="0.00"
            disabled={destroy}
            required
            onChange={onChange}
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

var React = require('react');
var BCInput = require('./bakecycle-input');

module.exports = React.createClass({
  errorFor: function(field) {
    if (!this.props.errors[field]) { return; }
    return (<small className="error">{this.props.errors[field]}</small>);
  },

  toggleDestroy: function() {
    var model = this.props.model;
    var destroy = model.get('destroy');
    model.set({ destroy: !destroy });
  },

  render: function() {
    var model = this.props.model;
    var { id, destroy } = model.toJSON();
    var namePrefix = `product[price_variants_attributes][${model.getNumericCID()}]`;
    var disabledClass = destroy ? 'disabled' : '';

    var undoButton = <a onClick={this.toggleDestroy} className="button alert postfix" >Undo</a>;
    var removeButton = <a onClick={this.toggleDestroy} className="test-remove-button button alert postfix" >X</a>;

    return (<div className={`fields ${disabledClass}`}>
      <input type="hidden" name={`${namePrefix}[id]`} value={id} />
      <input type="hidden" name={`${namePrefix}[_destroy]`} value={destroy} />
      <div className="row collapse">
        <div className="small-12 medium-4 columns">
          <label className="string required hide-for-medium-up">
            <abbr title="required">*</abbr>Price
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
        <div className="small-12 medium-4 columns">
          <label className="string required hide-for-medium-up">
            <abbr title="required">*</abbr>Quantity
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
        <div className="small-12 medium-4 columns">
          {destroy ? undoButton : removeButton}
        </div>
      </div>
    </div>);
  },
});

import React from 'react';
import formMixin from './bakecycle-form-mixin';

let BCRadio = React.createClass({
  mixins: [formMixin],

  propTypes: {
    disabled: React.PropTypes.bool,
    error: React.PropTypes.string,
    field: React.PropTypes.string.isRequired,
    label: React.PropTypes.string,
    model: React.PropTypes.object.isRequired,
    name: React.PropTypes.string.isRequired,
    options: React.PropTypes.array.isRequired,
    required: React.PropTypes.bool
  },

  makeRadio(option) {
    let label = option[0];
    let value = option[1];

    let {
      disabled,
      field,
      model,
      name,
    } = this.props;

    let isChecked = String(model.get(field)) === String(value);
    let id = `input-${field}-${model.cid}-${value}`;

    return (
      <span key={id}>
        <input
          id={id}
          type="radio"
          value={value}
          checked={isChecked}
          name={name}
          disabled={disabled}
          onChange={this.onChange}
        />
        <label htmlFor={id} >
          {label}
        </label>
      </span>
    );
  },

  render() {
    let {
      error,
      options,
    } = this.props;

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label()}
        {options.map(this.makeRadio)}
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCRadio;

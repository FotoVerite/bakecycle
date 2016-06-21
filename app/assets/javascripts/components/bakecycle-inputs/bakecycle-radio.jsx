import React from 'react';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCRadio = React.createClass({
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
    options: React.PropTypes.array.isRequired,
  },

  makeRadio(option) {
    const label = option[0];
    const labelValue = option[1];

    const {
      disabled,
      field,
      value,
      name,
    } = this.props;

    const cid = uniqueId();

    const isChecked = String(value) === String(labelValue);
    const id = `input-${field}-${cid}-${value}`;

    return (
      <span key={id}>
        <input
          id={id}
          type="radio"
          value={labelValue}
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
    const {
      error,
      options,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        {options.map(this.makeRadio)}
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCRadio;

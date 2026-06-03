import React from 'react';
import PropTypes from 'prop-types';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCRadio extends BakecycleInputBase {
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
          onChange={this.onChange.bind(this)}
        />
        <label htmlFor={id}>
          {label}
        </label>
      </span>
    );
  }

  render() {
    const {
      error,
      options,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        {options.map(this.makeRadio.bind(this))}
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCRadio.propTypes = {
  ...BakecycleInputBase.propTypes,
  options: PropTypes.array.isRequired,
};

export default BCRadio;

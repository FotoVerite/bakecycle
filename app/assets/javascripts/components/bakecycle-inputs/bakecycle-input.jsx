import React from 'react';
import PropTypes from 'prop-types';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCInput extends BakecycleInputBase {
  render() {
    const {
      autoComplete,
      disabled,
      error,
      field,
      inline,
      value,
      name,
      placeholder,
      step,
      type,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <input
          id={`input-${field}-${cid}`}
          className={`${type || 'text'} ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange.bind(this)}
          onBlur={this.onBlur.bind(this)}
          type={type || 'text'}
          placeholder={placeholder}
          value={value ?? ''}
          disabled={disabled}
          autoComplete={autoComplete}
          step={step}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCInput.propTypes = {
  ...BakecycleInputBase.propTypes,
  type: PropTypes.string,
  autoComplete: PropTypes.string,
};

export default BCInput;

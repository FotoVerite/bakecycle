import React from 'react';
import PropTypes from 'prop-types';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCCheckbox extends BakecycleInputBase {
  onClick(event) {
    const data = {};
    data[this.props.field] = event.target.checked;
    this.props.onChange(data);
  }

  render() {
    const {
      disabled,
      error,
      field,
      inline,
      value,
      name,
      type,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        <input
          id={`input-${field}-${cid}`}
          className={`${type || 'text'} ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onClick.bind(this)}
          type="checkbox"
          value={true}
          checked={value}
          disabled={disabled}
        />
        {this.label(cid)}
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCCheckbox.propTypes = {
  ...BakecycleInputBase.propTypes,
  type: PropTypes.string,
};

export default BCCheckbox;

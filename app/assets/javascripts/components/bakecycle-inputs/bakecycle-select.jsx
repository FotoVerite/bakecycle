import React from 'react';
import PropTypes from 'prop-types';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCSelect extends BakecycleInputBase {
  render() {
    const {
      disabled,
      error,
      field,
      includeBlank,
      inline,
      value,
      name,
      options,
    } = this.props;

    const cid = uniqueId();

    let blank;
    if (includeBlank) {
      blank = <option value="">{includeBlank}</option>;
    }

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <select
          id={`input-${field}-${cid}`}
          className={`select ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange.bind(this)}
          value={value || ''}
          disabled={disabled}
        >
          {blank}
          {options}
        </select>
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCSelect.displayName = 'BCSelect';
BCSelect.propTypes = {
  ...BakecycleInputBase.propTypes,
  options: PropTypes.array.isRequired,
  includeBlank: PropTypes.string,
};

export default BCSelect;

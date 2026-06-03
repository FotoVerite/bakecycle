import React from 'react';
import PropTypes from 'prop-types';
import ReactSelect from 'react-select';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCSearchableSelect extends BakecycleInputBase {
  render() {
    const {
      disabled,
      error,
      field,
      includeBlank,
      inline,
      value,
      multi,
      name,
      options,
      onChange,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <ReactSelect
          id={`input-${field}-${cid}`}
          options={options}
          placeholder={includeBlank}
          className={`select ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={value => onChange({[field]: value})}
          value={value || ''}
          disabled={disabled}
          simpleValue
          multi={multi || false}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCSearchableSelect.displayName = 'BCSelect';
BCSearchableSelect.propTypes = {
  ...BakecycleInputBase.propTypes,
  options: PropTypes.array.isRequired,
  includeBlank: PropTypes.string,
};

export default BCSearchableSelect;

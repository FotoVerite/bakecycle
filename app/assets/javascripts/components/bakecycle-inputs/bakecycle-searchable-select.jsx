import React from 'react';
import ReactSelect from 'react-select';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCSelect =  React.createClass({
  displayName: 'BCSelect',
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
    options: React.PropTypes.array.isRequired,
    includeBlank: React.PropTypes.string,
  },

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
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCSelect;

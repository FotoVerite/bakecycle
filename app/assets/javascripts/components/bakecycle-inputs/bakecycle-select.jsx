import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCSelect =  createReactClass({
  displayName: 'BCSelect',
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
    options: PropTypes.array.isRequired,
    includeBlank: PropTypes.string,
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
          onChange={this.onChange}
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
});

export default BCSelect;

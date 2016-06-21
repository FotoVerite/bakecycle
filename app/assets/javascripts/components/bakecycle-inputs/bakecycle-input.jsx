import React, { PropTypes } from 'react';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCInput = React.createClass({
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
    type: PropTypes.string,
    autoComplete: PropTypes.string,
  },

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
          onChange={this.onChange}
          type={type || 'text'}
          placeholder={placeholder}
          value={value}
          disabled={disabled}
          autoComplete={autoComplete}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCInput;

import React from 'react';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCTextArea = React.createClass({
  displayName: 'BCTextArea',
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
  },

  render() {
    const {
      disabled,
      error,
      field,
      inline,
      value,
      name,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <textarea
          id={`input-${field}-${cid}`}
          className={`textarea ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange}
          value={value}
          disabled={disabled}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCTextArea;

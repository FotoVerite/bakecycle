import React, { PropTypes } from 'react';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

const BCCheckbox = React.createClass({
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
    type: PropTypes.string
  },

  onClick(event) {
    const data = {};
    data[this.props.field] = event.target.checked;
    this.props.onChange(data);
  },

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
          onChange={this.onClick}
          type= "checkbox"
          value= {true}
          checked={value}
          disabled={disabled}
        />
        {this.label(cid)}
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCCheckbox;

import React from 'react';
import formMixin from './bakecycle-form-mixin';

let BCInput = React.createClass({
  mixins: [formMixin],

  propTypes: {
    disabled: React.PropTypes.bool,
    error: React.PropTypes.string,
    field: React.PropTypes.string.isRequired,
    label: React.PropTypes.string,
    model: React.PropTypes.object.isRequired,
    name: React.PropTypes.string.isRequired,
    placeholder: React.PropTypes.string,
    labelClass: React.PropTypes.string,
    required: React.PropTypes.bool,
    type: React.PropTypes.string,
    inline: React.PropTypes.bool,
  },

  getDefaultProps: function() {
    return {
      type: 'text'
    };
  },

  render: function() {
    let {
      disabled,
      error,
      field,
      inline,
      model,
      name,
      placeholder,
      type,
    } = this.props;

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label()}
        <input
          id={`input-${field}-${model.cid}`}
          className={`${type} ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange}
          type={type}
          placeholder={placeholder}
          value={model.get(field)}
          disabled={disabled}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCInput;

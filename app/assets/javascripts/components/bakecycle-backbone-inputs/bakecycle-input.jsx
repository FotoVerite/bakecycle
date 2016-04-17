import React from 'react';
import formMixin from './bakecycle-form-mixin';

const {PropTypes} = React;

let BCInput = React.createClass({
  mixins: [formMixin],

  propTypes: {
    disabled: PropTypes.bool,
    error: PropTypes.string,
    field: PropTypes.string.isRequired,
    label: PropTypes.string,
    model: PropTypes.object.isRequired,
    name: PropTypes.string.isRequired,
    placeholder: PropTypes.string,
    labelClass: PropTypes.string,
    required: PropTypes.bool,
    type: PropTypes.string,
    inline: PropTypes.bool,
    autoComplete: PropTypes.string,
  },

  getDefaultProps() {
    return {
      type: 'text'
    };
  },

  render() {
    let {
      disabled,
      error,
      field,
      inline,
      model,
      name,
      placeholder,
      type,
      autoComplete,
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
          autoComplete={autoComplete}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCInput;

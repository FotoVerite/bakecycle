import React, { PropTypes } from 'react';

export default {
  mixinPropTypes: {
    field: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    disabled: PropTypes.bool,
    error: PropTypes.string,
    inline: PropTypes.bool,
    label: PropTypes.string,
    labelClass: PropTypes.string,
    placeholder: PropTypes.string,
    required: PropTypes.bool,
    value: PropTypes.any,
  },

  requiredClass() {
    return this.props.required ? 'required' : 'optional';
  },

  onChange(event) {
    const data = {};
    data[this.props.field] = event.target.value;
    this.props.onChange(data);
  },

  labelClass() {
    return this.props.labelClass || '';
  },

  label(cid) {
    const {
      required,
      label,
      field,
    } = this.props;

    if (label) {
      return (
        <label
          className={`${this.labelClass()} ${this.requiredClass()}`}
          htmlFor={`input-${field}-${cid}`}
        >
          { label }
          { required ? <abbr title="required">*</abbr> : '' }
        </label>
      );
    }
  },
};

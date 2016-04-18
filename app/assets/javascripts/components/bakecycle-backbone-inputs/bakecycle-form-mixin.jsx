import React from 'react';

export default {
  requiredClass() {
    return this.props.required ? 'required' : 'optional';
  },

  onChange(event) {
    if (this.props.model) {
      const data = {};
      data[this.props.field] = event.target.value;
      this.props.model.set(data);
    }
  },

  label() {
    const {
      required,
      label,
      field,
      model,
      labelClass,
    } = this.props;

    if (label) {
      return (
        <label className={`${labelClass || ''} ${this.requiredClass()}`} htmlFor={`input-${field}-${model.cid}`}>
          {label} { required ? <abbr title="required">*</abbr> : '' }
        </label>
      );
    }
  },
};

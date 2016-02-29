import React from 'react';

export default {
  requiredClass: function() {
    return this.props.required ? 'required' : 'optional';
  },

  onChange: function(event) {
    if (this.props.model) {
      let data = {};
      data[this.props.field] = event.target.value;
      this.props.model.set(data);
    }
  },

  label: function() {
    let model = this.props.model;
    let {
      required,
      label,
      field,
      labelClass
    } = this.props;
    labelClass = labelClass || '';
    if (label) {
      return (
        <label className={`${labelClass} ${this.requiredClass()}`} htmlFor={`input-${field}-${model.cid}`}>
          {label} { required ? <abbr title="required">*</abbr> : '' }
        </label>
      );
    }
  },
};

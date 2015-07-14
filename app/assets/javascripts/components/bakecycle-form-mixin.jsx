var React = require('react');

module.exports = {
  requiredClass: function() {
    return this.props.required ? 'required' : 'optional';
  },

  onChange: function(event) {
    if (this.props.model) {
      var data = {};
      data[this.props.field] = event.target.value;
      this.props.model.set(data);
    }
  },

  label: function() {
    var model = this.props.model;
    var {
      required,
      label,
      field,
    } = this.props;
    if (label) {
      return (
        <label className={this.requiredClass()} htmlFor={`input-${field}-${model.cid}`}>
          {label} { required ? <abbr title="required">*</abbr> : '' }
        </label>
      );
    }
  },
};

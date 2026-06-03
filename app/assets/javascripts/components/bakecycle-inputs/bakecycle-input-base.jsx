import React from 'react';
import PropTypes from 'prop-types';

class BakecycleInputBase extends React.Component {
  requiredClass() {
    return this.props.required ? 'required' : 'optional';
  }

  onChange(event) {
    const data = {};
    data[this.props.field] = event.target.value;
    this.props.onChange(data);
  }

  onBlur(event) {
    if (this.props.onBlur == undefined) { return; }
    const data = {};
    data[this.props.field] = event.target.value;
    this.props.onBlur(data);
  }

  labelClass() {
    return this.props.labelClass || '';
  }

  label(cid) {
    const { required, label, field } = this.props;
    if (label) {
      return (
        <label
          className={`${this.labelClass()} ${this.requiredClass()}`}
          htmlFor={`input-${field}-${cid}`}
        >
          {label}
          {required ? <abbr title="required">*</abbr> : ''}
        </label>
      );
    }
  }
}

BakecycleInputBase.propTypes = {
  field: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
  onBlur: PropTypes.func,
  disabled: PropTypes.bool,
  checked: PropTypes.bool,
  error: PropTypes.string,
  inline: PropTypes.bool,
  label: PropTypes.string,
  labelClass: PropTypes.string,
  placeholder: PropTypes.string,
  required: PropTypes.bool,
  value: PropTypes.any,
};

export default BakecycleInputBase;

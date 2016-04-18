import React, { PropTypes } from 'react';
import formMixin from './bakecycle-form-mixin';
import moment from 'moment';
import DatePicker from 'react-datepicker';

// Set the first day of the week to be a Monday to match all other calendars
moment.updateLocale('en', {
  week : {
    dow : 1
  }
});

const BCDate = React.createClass({
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
    inline: PropTypes.bool,
    type: PropTypes.string
  },

  getDefaultProps() {
    return {
      type: 'text'
    };
  },

  onChangeDate(date) {
    const data = {};
    data[this.props.field] = date && date.format();
    this.props.model.set(data);
  },

  render() {
    const {
      disabled,
      error,
      field,
      inline,
      model,
      name,
      placeholder,
      type,
    } = this.props;

    const date = model.get(field) && moment(model.get(field));

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label()}
        <input
          type="hidden"
          name={name}
          value={model.get(field)}
          disabled={disabled}
        />

        <DatePicker
          id={`input-${field}-${model.cid}`}
          selected={date}
          onChange={this.onChangeDate}
          placeholderText={placeholder}
          todayButton="Today"
          className={`${type} ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
        />

        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCDate;

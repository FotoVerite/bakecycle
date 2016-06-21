import DatePicker from 'react-datepicker';
import moment from 'moment';
import React from 'react';
import uniqueId from 'lodash.uniqueid';
import formMixin from './bakecycle-form-mixin';

// Set the first day of the week to be a Monday to match all other calendars
moment.updateLocale('en', {
  week : {
    dow : 1
  }
});

const BCDate = React.createClass({
  mixins: [formMixin],

  propTypes: {
    ...formMixin.mixinPropTypes,
  },

  onChangeDate(date) {
    const data = {};
    data[this.props.field] = date && date.format('YYYY-MM-DD');
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
      placeholder,
    } = this.props;

    const date = value && moment(value);
    const cid = uniqueId();

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <input
          type="hidden"
          name={name}
          value={value}
          disabled={disabled}
        />

        <DatePicker
          id={`input-${field}-${cid}`}
          selected={date}
          onChange={this.onChangeDate}
          placeholderText={placeholder}
          todayButton="Today"
          className={`text ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
        />

        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCDate;

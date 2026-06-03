import React from 'react';
import DatePicker from 'react-datepicker';
import moment from 'moment';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCDate extends BakecycleInputBase {
  onChangeDate(date) {
    const data = {};
    data[this.props.field] = date ? moment(date).format('YYYY-MM-DD') : null;
    this.props.onChange(data);
  }

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

    // react-datepicker v4 uses Date objects; parse from YYYY-MM-DD string
    // Use T00:00:00 to avoid UTC offset shifting the date by one day
    const date = value ? new Date(value + 'T00:00:00') : null;
    const cid = uniqueId();

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <input
          type="hidden"
          name={name}
          value={value || ''}
          disabled={disabled}
        />
        <DatePicker
          id={`input-${field}-${cid}`}
          selected={date}
          onChange={this.onChangeDate.bind(this)}
          placeholderText={placeholder}
          todayButton="Today"
          calendarStartDay={1}
          className={`text ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          dateFormat="yyyy-MM-dd"
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

export default BCDate;

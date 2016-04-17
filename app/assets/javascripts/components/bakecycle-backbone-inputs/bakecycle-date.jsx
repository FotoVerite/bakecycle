import React from 'react';
import formMixin from './bakecycle-form-mixin';
import moment from 'moment';
import DatePicker from 'react-datepicker';

// Set the first day of the week to be a Monday to match all other calendars
moment.updateLocale('en', {
  week : {
    dow : 1
  }
});

let BCDate = React.createClass({
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
    inline: React.PropTypes.bool,
  },

  getDefaultProps() {
    return {
      type: 'text'
    };
  },

  onChangeDate(date) {
    let data = {};
    data[this.props.field] = date && date.format();
    this.props.model.set(data);
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
    } = this.props;

    let date = model.get(field) && moment(model.get(field));

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

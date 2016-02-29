import React from 'react';
import formMixin from './bakecycle-form-mixin';

let BCSelect =  React.createClass({
  displayName: 'BCSelect',
  mixins: [formMixin],

  propTypes: {
    disabled: React.PropTypes.bool,
    error: React.PropTypes.string,
    field: React.PropTypes.string.isRequired,
    label: React.PropTypes.string,
    model: React.PropTypes.object.isRequired,
    name: React.PropTypes.string.isRequired,
    options: React.PropTypes.array.isRequired,
    required: React.PropTypes.bool,
    inline: React.PropTypes.bool,
    includeBlank: React.PropTypes.string
  },

  render: function() {
    let {
      disabled,
      error,
      field,
      inline,
      model,
      name,
      options,
      includeBlank
    } = this.props;

    let blank;
    if (includeBlank) {
      blank = <option value="">{includeBlank}</option>;
    }

    return (
      <div className={`input select ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label()}
        <select
          id={`input-${field}-${model.cid}`}
          className={`select ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange}
          value={model.get(field)}
          disabled={disabled}
        >
          {blank}
          {options}
        </select>
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCSelect;

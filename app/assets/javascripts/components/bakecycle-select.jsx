var React = require('react');
var formMixin = require('./bakecycle-form-mixin');

module.exports = React.createClass({
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
    inline: React.PropTypes.bool
  },

  render: function() {
    var {
      disabled,
      error,
      field,
      inline,
      model,
      name,
      options,
    } = this.props;

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
          {options}
        </select>
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

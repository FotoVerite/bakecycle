var React = require('react');

module.exports = React.createClass({
  propTypes: {
    model: React.PropTypes.object.isRequired,
    field: React.PropTypes.string.isRequired,
    name: React.PropTypes.string.isRequired,
    label: React.PropTypes.string.isRequired,
    required: React.PropTypes.bool,
    error: React.PropTypes.string,
  },

  onChange: function(event) {
    if (this.props.model) {
      var data = {};
      data[this.props.field] = event.target.value;
      this.props.model.set(data);
    }
  },

  render: function() {
    var {
      model,
      required,
      name,
      label,
      field,
      error,
    } = this.props;

    var requiredClass = required ? 'required' : 'optional';

    return (
      <div className={`input ${requiredClass} ${error ? 'error' : ''}`}>
        <label className="string required" htmlFor={`input-${field}`}>
          {label} { required ? <abbr title="required">*</abbr> : '' }
        </label>
        <textarea
          id={`input-${field}`}
          className={`string ${requiredClass}`}
          name={name}
          onChange={this.onChange}
          value={model.get(field)} />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

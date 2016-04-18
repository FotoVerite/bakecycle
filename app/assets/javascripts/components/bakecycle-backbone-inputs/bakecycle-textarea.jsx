import React from 'react';
import formMixin from './bakecycle-form-mixin';

const BCTextArea = React.createClass({
  displayName: 'BCTextArea',
  mixins: [formMixin],

  propTypes: {
    disabled: React.PropTypes.bool,
    error: React.PropTypes.string,
    field: React.PropTypes.string.isRequired,
    inline: React.PropTypes.bool,
    label: React.PropTypes.string,
    model: React.PropTypes.object.isRequired,
    name: React.PropTypes.string.isRequired,
    required: React.PropTypes.bool
  },

  render() {
    const {
      disabled,
      error,
      field,
      inline,
      model,
      name,
    } = this.props;

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label()}
        <textarea
          id={`input-${field}-${model.cid}`}
          className={`textarea ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange}
          value={model.get(field)}
          disabled={disabled}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
});

export default BCTextArea;

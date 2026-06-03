import React from 'react';
import uniqueId from 'lodash.uniqueid';
import BakecycleInputBase from './bakecycle-input-base';

class BCTextArea extends BakecycleInputBase {
  render() {
    const {
      disabled,
      error,
      field,
      inline,
      value,
      name,
    } = this.props;

    const cid = uniqueId();

    return (
      <div className={`input ${this.requiredClass()} ${error ? 'error' : ''}`}>
        {this.label(cid)}
        <textarea
          id={`input-${field}-${cid}`}
          className={`textarea ${field} ${this.requiredClass()} ${inline ? 'inline' : ''}`}
          name={name}
          onChange={this.onChange.bind(this)}
          value={value ?? ''}
          disabled={disabled}
        />
        {error ? <small className="error">{error}</small> : ''}
      </div>
    );
  }
}

BCTextArea.displayName = 'BCTextArea';

export default BCTextArea;

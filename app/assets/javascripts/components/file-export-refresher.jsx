import React, { PropTypes } from 'react';
import { Model as FileExportStore } from 'backbone';

const FileExportRefresher = React.createClass({
  propTypes: {
    links: PropTypes.object.isRequired,
    loadingMessage: PropTypes.string.isRequired,
  },

  getInitialState() {
    return {
      status: '',
      ready: false
    };
  },

  componentWillMount() {
    this.store = new FileExportStore();
    this.store.on('change', store => this.setState(store.toJSON()));
    this.store.set(this.props);
    this.poll();
  },

  componentWillUnmount() {
    this.store.off('change');
    this.stopPoll();
  },

  poll() {
    this.jxr = $.get(this.props.links.self);
    this.jxr.done(data => this.store.set(data));
    this.jxr.done(() => this.status(''));
    this.jxr.done((data) => {
      if (!data.ready) {
        this.timeout = window.setTimeout(this.poll, 1000);
      }
    });

    this.jxr.fail(() => this.status('There was an error checking on the report, trying again in 5 seconds.'));
    this.jxr.fail(() => this.timeout = window.setTimeout(this.poll, 5000));
  },

  status(message) {
    this.setState({status: message});
  },

  stopPoll() {
    window.clearTimeout(this.timeout);
    if (this.jxr) { this.jxr.abort(); }
  },

  componentWillReceiveProps(newProps) {
    this.store.update(newProps);
  },

  loading() {
    return (
      <div>
        <h2 className="loading-message">{this.props.loadingMessage}</h2>
        <div className="loading-indicator">
          <div className="bounce1"></div>
          <div className="bounce2"></div>
          <div className="bounce3"></div>
        </div>
        <div>{this.state.status}</div>
      </div>
    );
  },

  complete() {
    window.location.replace(this.state.links.file);
    return (
      <div>
        <h1>The report is ready!</h1>
        <p>
          It should begine downloading in a moment.
          If it doesn't you can <a href={this.state.links.file} className="underlined-link">click here</a> to download it now.
        </p>
      </div>
    );
  },

  render() {
    return (<div className="loading-report">
      {this.state.ready ? this.complete() : this.loading()}
    </div>);
  }
});

export default FileExportRefresher;

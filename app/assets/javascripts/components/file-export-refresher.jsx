import React from 'react';
import PropTypes from 'prop-types';

class FileExportRefresher extends React.Component {
  constructor(props) {
    super(props);
    this.state = { status: '', ready: false };
    this.poll = this.poll.bind(this);
  }

  componentDidMount() {
    this.poll();
  }

  componentWillUnmount() {
    this.stopPoll();
  }

  poll() {
    this.jxr = $.get(this.props.links.self);
    this.jxr.done(data => this.setState(data));
    this.jxr.done(() => this.setState({ status: '' }));
    this.jxr.done((data) => {
      if (!data.ready) {
        this.timeout = window.setTimeout(this.poll, 1000);
      }
    });
    this.jxr.fail(() => this.setState({ status: 'There was an error checking on the report, trying again in 5 seconds.' }));
    this.jxr.fail(() => { this.timeout = window.setTimeout(this.poll, 5000); });
  }

  stopPoll() {
    window.clearTimeout(this.timeout);
    if (this.jxr) { this.jxr.abort(); }
  }

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
  }

  complete() {
    window.location.replace(this.state.links.file);
    return (
      <div>
        <h1>The report is ready!</h1>
        <p>
          It should begine downloading in a moment.
          If it doesn&#39;t you can <a href={this.state.links.file} className="underlined-link">click here</a> to download it now.
        </p>
      </div>
    );
  }

  render() {
    return (
      <div className="loading-report">
        {this.state.ready ? this.complete() : this.loading()}
      </div>
    );
  }
}

FileExportRefresher.propTypes = {
  links: PropTypes.object.isRequired,
  loadingMessage: PropTypes.string.isRequired,
};

export default FileExportRefresher;

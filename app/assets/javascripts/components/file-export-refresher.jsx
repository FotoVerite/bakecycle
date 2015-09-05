var React = require('react');
var FileExportStore = require('backbone').Model;

module.exports = React.createClass({

  getInitialState: function() {
    return {
      status: '',
      ready: false
    };
  },

  componentWillMount: function() {
    this.store = new FileExportStore();
    this.store.on('change', store => this.setState(store.toJSON()));
    this.store.set(this.props);
    this.poll();
  },

  componentWillUnmount: function() {
    this.store.off('change');
    this.stopPoll();
  },

  poll: function() {
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

  status: function(message) {
    this.setState({status: message});
  },

  stopPoll: function() {
    window.clearTimeout(this.timeout);
    if (this.jxr) { this.jxr.abort(); }
  },

  componentWillReceiveProps: function(newProps) {
    this.store.update(newProps);
  },

  render: function() {
    if (this.state.ready) {
      window.location.replace(this.state.links.file);
      return <div>The report is ready!</div>;
    }

    return <div>{this.state.status}</div>;
  }
});

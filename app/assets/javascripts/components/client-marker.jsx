var React = require('react');

var Marker = React.createClass({
  render() {
    var className = this.props.$hover ? 'map-marker hover' : 'map-marker';
    return (
      <div className={className} title={this.props.title}>
        {this.props.children}
      </div>
    );
  }
});

module.exports = Marker;

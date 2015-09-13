var React = require('react');

var Marker = React.createClass({
  render() {
    var className = this.props.$hover ? 'map-marker hover' : 'map-marker';
    return (
      <div
        className={className}
        title={this.props.title}
        onClick={this.props.onClick} >
        {this.props.children}
      </div>
    );
  }
});

module.exports = Marker;

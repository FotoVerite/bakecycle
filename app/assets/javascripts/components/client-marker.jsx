let React = require('react');

let Marker = React.createClass({
  render() {
    let className = this.props.$hover ? 'map-marker hover' : 'map-marker';
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

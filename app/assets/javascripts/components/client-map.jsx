var GoogleMap = require('google-map-react');
var Marker = require('./client-marker');
var React = require('react');

module.exports = React.createClass({

  propTypes: {
    name: React.PropTypes.string.isRequired,
    longitude: React.PropTypes.number.isRequired,
    latitude: React.PropTypes.number.isRequired
  },

  componentDidMount: function() {
    window.addEventListener('resize', this.onResize);
  },

  componentWillUnmount: function() {
    window.removeEventListener('resize', this.onResize);
  },

  onResize() {
    var width = window.innerWidth;
    this.setState({width});
  },

  mapOptions: {
    'min-zoom': 15,
    'max-zoom': 15,
    scrollwheel: false,
    draggable: false
  },

  openMap() {
    var { deliveryAddressFull } = this.props;
    window.open(`http://maps.google.com/?q=${encodeURIComponent(deliveryAddressFull)}`);
  },

  render() {
    var center = [this.props.latitude, this.props.longitude];
    return (<div className="map-container">
      <GoogleMap
        ref="gmap"
        center={center}
        zoom={15}
        options={this.mapOptions} >
        <Marker
          lat={this.props.latitude}
          lng={this.props.longitude}
          title={this.props.name}
          onClick={this.openMap} >

        </Marker>
      </GoogleMap>
    </div>);
  }
});

let GoogleMap = require('google-map-react');
let Marker = require('./client-marker');
let React = require('react');

var ClientMap = React.createClass({
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
    let width = window.innerWidth;
    this.setState({width});
  },

  mapOptions: {
    'min-zoom': 15,
    'max-zoom': 15,
    scrollwheel: false,
    draggable: false
  },

  openMap() {
    let { deliveryAddressFull } = this.props;
    window.open(`http://maps.google.com/?q=${encodeURIComponent(deliveryAddressFull)}`);
  },

  render() {
    let center = [this.props.latitude, this.props.longitude];
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

module.exports = ClientMap;

import React, { PropTypes } from 'react';
import GoogleMap from 'google-map-react';
import Marker from './client-marker';

const ClientMap = React.createClass({
  propTypes: {
    name: PropTypes.string.isRequired,
    longitude: PropTypes.number.isRequired,
    latitude: PropTypes.number.isRequired,
    deliveryAddressFull: PropTypes.string.isRequired,
  },

  componentDidMount() {
    window.addEventListener('resize', this.onResize);
  },

  componentWillUnmount() {
    window.removeEventListener('resize', this.onResize);
  },

  onResize() {
    const width = window.innerWidth;
    this.setState({width});
  },

  mapOptions: {
    'min-zoom': 15,
    'max-zoom': 15,
    scrollwheel: false,
    draggable: false
  },

  openMap() {
    const { deliveryAddressFull } = this.props;
    window.open(`http://maps.google.com/?q=${encodeURIComponent(deliveryAddressFull)}`);
  },

  render() {
    const center = [this.props.latitude, this.props.longitude];
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

export default ClientMap;

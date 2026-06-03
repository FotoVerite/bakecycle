import React from 'react';
import PropTypes from 'prop-types';
import GoogleMap from 'google-map-react';
import Marker from './client-marker';

class ClientMap extends React.Component {
  constructor(props) {
    super(props);
    this.onResize = this.onResize.bind(this);
    this.openMap = this.openMap.bind(this);
  }

  componentDidMount() {
    window.addEventListener('resize', this.onResize);
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.onResize);
  }

  onResize() {
    this.setState({ width: window.innerWidth });
  }

  openMap() {
    window.open(`http://maps.google.com/?q=${encodeURIComponent(this.props.deliveryAddressFull)}`);
  }

  render() {
    const { latitude, longitude, name, apiKey } = this.props;
    const center = { lat: latitude, lng: longitude };
    const mapOptions = {
      scrollwheel: false,
      draggable: false,
      minZoom: 15,
      maxZoom: 15,
    };
    return (
      <div className="map-container">
        <GoogleMap
          bootstrapURLKeys={{ key: apiKey }}
          center={center}
          zoom={15}
          options={mapOptions}
        >
          <Marker
            lat={latitude}
            lng={longitude}
            title={name}
            onClick={this.openMap}
          />
        </GoogleMap>
      </div>
    );
  }
}

ClientMap.propTypes = {
  name: PropTypes.string.isRequired,
  longitude: PropTypes.number.isRequired,
  latitude: PropTypes.number.isRequired,
  deliveryAddressFull: PropTypes.string.isRequired,
  apiKey: PropTypes.string.isRequired,
};

export default ClientMap;

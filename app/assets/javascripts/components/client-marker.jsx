import React, { PropTypes } from 'react';

export default function Marker({$hover, title, onClick, children}){
  const className = $hover ? 'map-marker hover' : 'map-marker';
  return (
    <div
      className={className}
      title={title}
      onClick={onClick} >
      {children}
    </div>
  );
}

Marker.propTypes = {
  '$hover': PropTypes.bool,
  title: PropTypes.string,
  onClick: PropTypes.func,
  children: PropTypes.node,
};

// Shim for packages predating the React 15.5/16 API splits (react-select 1.x, etc.)
// Must be the first import in app.js so these are set before any CJS package initializes.
import React from 'react';
import PropTypes from 'prop-types';
import createReactClass from 'create-react-class';
React.PropTypes = PropTypes;
React.createClass = createReactClass;

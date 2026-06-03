// Used by Jest only. esbuild handles production bundling without Babel.
module.exports = {
  presets: [
    ['@babel/preset-env', { targets: { node: 'current' } }],
    ['@babel/preset-react'],
  ],
};

/*eslint object-shorthand: 0*/
window.Stripe = {
  setPublishableKey: function() { },
  card: {
    createToken: function(data, cb) {
      cb(200, {id: 'hi'});
    }
  }
};

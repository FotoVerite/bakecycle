(function() {
  var stripeResponseHandler = function(status, response) {
    if (response.error) {
      errorHandler(response);
    } else {
      successHandler(response);
    }
  };

  var errorHandler = function(response) {
    var $form = $('#registration-form');
    $form.find('.payment-errors').text(response.error.message);
    $form.find('button').prop('disabled', false);
  };

  var successHandler = function(response) {
    var $form = $('#registration-form');
    var token = response.id;
    $form.append($('<input type="hidden" name="registration[stripe_token]" />').val(token));
    $form.get(0).submit();
  };

  var formHandler = function(event) {
    event.preventDefault();
    var $form = $(this);
    var stripeRequiredInfo = {
      number: $('[data-stripe=number]').val(),
      cvc: $('[data-stripe=cvc]').val(),
      exp_month: $('[data-stripe=exp-month]').val(),
      exp_year: $('[data-stripe=exp-year]').val(),
      address_zip: $('[data-stripe=address_zip]').val()
    };

    $form.find('button').prop('disabled', true);
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));
    Stripe.card.createToken(stripeRequiredInfo, stripeResponseHandler);
  };

  $(function() {
    $('#registration-form').on('submit', formHandler);
  });
})();

# fill forms faster with jQuery
# rubocop:disable Metrics/MethodLength
def jquery_fill(fields_hash)
  page.execute_script "
  (function(){
    var fields = #{fields_hash.to_json};
    Object.keys(fields).forEach(function(key){
      var $target = $(key);
      var value = fields[key];

      if(!$target.get(0)) {
        $('body').text('jquery_fill error cannot find ' + key);
      }

      if ($target.is('input:radio')) {
        $target.click();
        return;
      }

      if ($target.is('select')) {
        var id = $target.find('option:contains(\"' + value +'\")').val();
        $target.val(id).trigger('input');
        return;
      }

      // set the value and trigger an input event for angular
      $target.val(value).trigger('input');
    });
  })();
  "
end

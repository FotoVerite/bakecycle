
def jquery_fill(fields_hash)
  page.execute_script "
    var fields = #{fields_hash.to_json};
    Object.keys(fields).forEach(function(key){
      $('#' + key).val(fields[key]);
    });
  "
end

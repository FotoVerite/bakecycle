require 'rails_helper'
require 'legacy_importer'

describe LegacyImporter do
  let(:bakery) { create(:bakery) }
  let(:connection) { instance_double(Mysql2::Client, query: []) }
end

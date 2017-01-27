# == Schema Information
#
# Table name: bakeries
#
#  id                 :integer          not null, primary key
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string
#  phone_number       :string
#  address_street_1   :string
#  address_street_2   :string
#  address_city       :string
#  address_state      :string
#  address_zipcode    :string
#  logo_file_name     :string
#  logo_content_type  :string
#  logo_file_size     :integer
#  logo_updated_at    :datetime
#  kickoff_time       :time             not null
#  last_kickoff       :datetime
#  quickbooks_account :string           not null
#  group_preferments  :boolean          default(TRUE)
#  plan_id            :integer          not null
#  stripe_customer_id :string
#

require "rails_helper"

describe Bakery do
  let(:bakery) { build(:bakery) }

  it "has model attributes" do
    expect(bakery).to respond_to(:name)
    expect(bakery).to respond_to(:logo)
    expect(bakery).to respond_to(:email)
    expect(bakery).to respond_to(:phone_number)
    expect(bakery).to respond_to(:address_street_1)
    expect(bakery).to respond_to(:address_street_2)
    expect(bakery).to respond_to(:address_city)
    expect(bakery).to respond_to(:address_state)
    expect(bakery).to respond_to(:address_zipcode)
    expect(bakery).to respond_to(:ingredients)
    expect(bakery).to respond_to(:clients)
    expect(bakery).to respond_to(:recipes)
    expect(bakery).to respond_to(:orders)
    expect(bakery).to respond_to(:products)
    expect(bakery).to respond_to(:routes)
    expect(bakery).to respond_to(:shipments)
    expect(bakery).to respond_to(:users)
    expect(bakery).to respond_to(:kickoff_time)
    expect(bakery).to respond_to(:last_kickoff)
  end

  it "has validations" do
    expect(bakery).to validate_presence_of(:name)
    expect(bakery).to validate_length_of(:name).is_at_most(150)
    expect(bakery).to validate_uniqueness_of(:name)
    expect(bakery).to validate_presence_of(:plan)
  end

  describe "#logo_local_file" do
    it "gives the path of the logo" do
      bakery = create(:bakery, :with_logo)
      expect(bakery.logo_local_file).to include(".png")
    end

    it "returns nil with no logo" do
      bakery = create(:bakery)
      expect(bakery.logo_local_file).to be_nil
    end
  end
end

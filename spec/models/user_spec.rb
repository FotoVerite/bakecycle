# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  bakery_id              :integer
#  admin                  :boolean          default(FALSE)
#  user_permission        :string           default("none"), not null
#  product_permission     :string           default("none"), not null
#  bakery_permission      :string           default("none"), not null
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  client_permission      :string           default("none"), not null
#  shipping_permission    :string           default("none"), not null
#  production_permission  :string           default("none"), not null
#

require "rails_helper"

describe User do
  let(:user) { build(:user) }

  it "has association" do
    expect(user).to belong_to(:bakery)
  end

  it "has validations" do
    expect(user).to validate_length_of(:name)
    expect(user).to validate_presence_of(:user_permission)
    expect(user).to validate_inclusion_of(:user_permission).in_array(User::ACCESS_LEVELS)
    expect(user).to validate_presence_of(:email)
    user.email = "test@example.com"
    expect(user).to validate_uniqueness_of(:email).case_insensitive
  end

  describe ".sort_by_bakery_and_name" do
    it "sorts users with bakery first and sorts by name afterwards" do
      no_bakery = create(:user, bakery: nil)
      a_bakery = create(:bakery, name: "a bakery")
      john = create(:user, name: "john", bakery: a_bakery)
      david = create(:user, name: "David", bakery: a_bakery)
      bob = create(:user, name: "bob", bakery: create(:bakery, name: "B bakery"))
      aria = create(:user, name: "aria", bakery: create(:bakery, name: "c bakery"))
      expect(User.sort_by_bakery_and_name).to eq([david, john, bob, aria, no_bakery])
    end
  end
end

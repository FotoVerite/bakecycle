require "rails_helper"

describe Route do
  let(:route) { build(:route) }

  describe "Route" do
    describe "model attributes" do
      it { expect(route).to respond_to(:name) }
      it { expect(route).to respond_to(:notes) }
      it { expect(route).to respond_to(:active) }
      it { expect(route).to respond_to(:departure_time) }
    end

    describe "validations" do

      describe "name" do
        it { expect(route).to validate_presence_of(:name) }
        it { expect(route).to ensure_length_of(:name).is_at_most(150) }
      end

      describe "departure time" do
        it { expect(route).to validate_presence_of(:departure_time) }

        it "it is a time" do
          expect(build(:route, departure_time: Time.now)).to be_valid
          expect(build(:route, departure_time: "it is not a time")).to_not be_valid
        end
      end
    end
  end
end

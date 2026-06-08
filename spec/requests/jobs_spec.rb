# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Jobs dashboard", type: :request do
  let(:bakery) { create(:bakery) }
  let(:admin)  { create(:user, :as_admin, bakery: bakery) }

  before { sign_in admin }

  it "loads the mounted Mission Control dashboard" do
    queue_adapter = ActiveJob::Base.queue_adapter
    without_partial_double_verification do
      allow(queue_adapter).to receive(:queues).and_return([])
      allow(queue_adapter).to receive(:jobs_count).and_return(0)
      allow(queue_adapter).to receive(:fetch_jobs).and_return([])
    end

    get "/jobs"

    expect(response).to be_successful
    expect(response.body).to include("Mission control - Queues")
  end
end

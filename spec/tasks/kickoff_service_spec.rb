require "rails_helper"

RSpec.describe "bakecycle:kickoff", type: :task do
  it "runs the kickoff service" do
    expect(KickoffService).to receive(:run)

    expect { rake_task("bakecycle:kickoff").invoke }.to output(
      "Kickoff Starting\nKickoff finished\n"
    ).to_stdout
  end
end

require 'rails_helper'
describe DemoCreatorJob do
  let(:bakery) { create(:bakery) }

  describe '#perform' do
    it 'creats demodata for the bakery' do
      expect_any_instance_of(DemoCreator).to receive(:run)
      DemoCreatorJob.new.perform(bakery)
    end

    it 'is idempotent' do
      expect_any_instance_of(DemoCreator).to receive(:run) do |creator|
        create(:client, name: 'demo client', bakery: creator.bakery)
      end
      DemoCreatorJob.new.perform(bakery)
      expect(bakery.clients.count).to eq(1)
      DemoCreatorJob.new.perform(bakery)
      expect(bakery.clients.count).to eq(1)
    end

    it 're-enqueues itself when terminated' do
      expect_any_instance_of(DemoCreator).to receive(:run).and_raise(Resque::TermException, 'TERM')
      expect { DemoCreatorJob.new.perform(bakery) }.to enqueue_a(DemoCreatorJob)
    end
  end
end

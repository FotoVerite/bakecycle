require 'rails_helper'

describe RunItem do
  describe '#create' do
    it 'calls RunItemQuantifier' do
      expect_any_instance_of(RunItemQuantifier).to receive(:set)
      run_item = build(:run_item)
      run_item.save
    end
  end
end

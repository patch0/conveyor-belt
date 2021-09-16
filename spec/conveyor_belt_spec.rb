# frozen_string_literal: true

require 'conveyor_belt'

RSpec.describe ConveyorBelt do
  subject { described_class.new(length) }
  let(:length) { 10 }
  let(:slot) { length - 1 }

  context 'when the last slot has a component' do
    before do
      subject.put_down(slot - 1, 'A')
      subject.move_along
    end

    it 'only allows one item per slot' do
      expect { subject.put_down(slot, 'B') }.to raise_exception(ConveyorBelt::SlotFull)
    end

    it 'does not allow a collect then a put on the same slot' do
      subject.pick_up(slot)
      expect { subject.put_down(slot, 'B') }.to raise_exception(ConveyorBelt::SlotModified)
    end

    it 'counts unused components from the end of the belt' do
      expect(subject.finished_counts['A']).to be_zero
      subject.move_along
      expect(subject.finished_counts['A']).to eq 1
    end
  end

  context 'when the last slot has a finished product' do
    before do
      subject.put_down(slot - 1, 'P')
      subject.move_along
    end

    it 'counts finished products from the end of the belt' do
      expect(subject.finished_counts['P']).to be_zero
      subject.move_along
      expect(subject.finished_counts['P']).to eq 1
    end
  end
end

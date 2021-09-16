# frozen_string_literal: true

require 'worker'

RSpec.describe Worker do
  subject { described_class.new(conveyor_belt, seat) }
  let(:seat) { 0 }
  let(:conveyor_belt) { instance_double('conveyor_belt') }

  context 'when worker has all components' do
    before do
      # Ensure our worker has everything they need
      expect(conveyor_belt).to receive(:peek_at).with(seat).and_return('A', 'B')
      expect(conveyor_belt).to receive(:pick_up).with(seat).and_return('A', 'B')
      2.times { subject.work }
    end

    it 'puts product down after a set assembly time' do
      # We should run three times and on the 4th put down our product
      3.times { subject.work }
      # We still have our components
      expect(subject.components).to match('A' => 1, 'B' => 1)
      expect(conveyor_belt).to receive(:put_down).with(seat, 'P')
      subject.work
      expect(subject.components).to match({})
    end

    context 'when the slot is already full' do
      it 'waits until the next empty slot' do
        # We should run three times and on the 4th put down our product
        3.times { subject.work }
        # We still have our components
        expect(subject.components).to match('A' => 1, 'B' => 1)
        expect(conveyor_belt).to receive(:put_down).with(seat, 'P').and_raise(ConveyorBelt::SlotFull)

        subject.work
        # Check nothing has changed.
        expect(subject.components).to match('A' => 1, 'B' => 1)
      end
    end
  end

  context 'when the worker see an uneeded component' do
    it "doesn't pick it up and increments the time blocked counter" do
      expect(conveyor_belt).to receive(:peek_at).with(seat).and_return('A', 'A')
      expect(conveyor_belt).to receive(:pick_up).with(seat).and_return('A')
      subject.work

      expect(subject.time_blocked).to be_zero
      expect(subject.components).to match('A' => 1)

      subject.work
      expect(subject.time_blocked).to eq 1
      expect(subject.components).to match('A' => 1)
    end
  end
end

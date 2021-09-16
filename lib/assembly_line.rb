# frozen_string_literal: true

require 'conveyor_belt'
require 'worker'

class AssemblyLine
  def initialize(worker_count = 2, workers_per_slot = 2)
    slot_count = (worker_count.to_f / workers_per_slot).ceil
    @conveyor_belt = ConveyorBelt.new(slot_count)

    @workers = []
    slot_count.times do |slot|
      workers_per_slot.times do
        @workers << Worker.new(@conveyor_belt, slot)
        break if @workers.size == worker_count
      end
    end
  end

  def run(iterations = 100)
    iterations.times do
      @workers.each(&:work)
      @conveyor_belt.move_along
    end
    pp @conveyor_belt.finished_counts
    # pp @workers.sum(&:time_blocked)
  end
end

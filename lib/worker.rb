# frozen_string_literal: true

require 'conveyor_belt'

class Worker
  # These are the counts of each component required to make a product.
  REQUIRED_COMPONENTS = { 'A' => 1, 'B' => 1 }.freeze
  ASSEMBLY_TIME = 4

  attr_reader :conveyor_belt, :seat, :components, :time_blocked

  def initialize(conveyor_belt, seat)
    @conveyor_belt = conveyor_belt
    @seat = seat
    @components = Hash.new { |h, k| h[k] = 0 }
    @assembly_time = 0
    @time_blocked = 0
  end

  def work
    if ready_to_assemble?
      assemble
    else
      pick_component_from_belt
    end
  end

  private

  def ready_to_assemble?
    REQUIRED_COMPONENTS == @components
  end

  def assemble
    @assembly_time += 1

    put_on_belt if @assembly_time >= ASSEMBLY_TIME
  end

  def put_on_belt
    conveyor_belt.put_down(seat, 'P')
    @components = Hash.new { |h, k| h[k] = 0 }
  rescue ConveyorBelt::SlotFull, ConveyorBelt::SlotModified
    @time_blocked += 1
  end

  def pick_component_from_belt
    item = conveyor_belt.peek_at(seat)
    if REQUIRED_COMPONENTS.key?(item) &&
       REQUIRED_COMPONENTS[item] > components[item]
      item = conveyor_belt.pick_up(seat)
      components[item] += 1
    else
      @time_blocked += 1
    end
  end
end

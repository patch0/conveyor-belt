# frozen_string_literal: true

class ConveyorBelt
  class SlotModified < StandardError; end
  class SlotFull < StandardError; end

  # This is a list of components that are produced.  The frequency of component
  # types (or nils) dictates how often a particular component is produced at
  # the start of the belt.
  COMPONENT_FREQS = ['A', 'B', nil].freeze

  attr_reader :finished_counts, :slots

  def initialize(length)
    @slot_count = length
    @slots = Array.new(@slot_count)
    @slot_locks = Array.new(@slot_count)

    @finished_counts = Hash.new { |h, k| h[k] = 0 }
  end

  def move_along
    clear_locks
    populate_start_of_belt
    collect_from_end_of_belt
  end

  def pick_up(slot)
    lock_slot(slot)

    item = slots[slot]
    slots[slot] = nil

    # Don't clear lock, as only one operation can be run at a time on a slot
    item
  end

  def put_down(slot, item)
    raise SlotFull, "slot #{slot} already full" if slots[slot]

    lock_slot(slot)
    slots[slot] = item
  end

  def peek_at(slot)
    slots[slot]
  end

  private

  def populate_start_of_belt
    slots.unshift(COMPONENT_FREQS.sample)
  end

  def collect_from_end_of_belt
    item = slots.pop
    return if item.nil?

    @finished_counts[item] += 1

    item
  end

  def lock_slot(slot)
    raise SlotModified, "slot #{slot} already modified" if @slot_locks[slot]

    @slot_locks[slot] = true
  end

  def clear_locks
    @slot_locks = Array.new(@slot_count)
  end
end

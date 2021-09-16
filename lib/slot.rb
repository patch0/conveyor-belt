# frozen_string_literal: true

class Slot
  class SlotModified < StandardError; end
  class SlotFull < StandardError; end

  def initialize
    @contents = nil
    @modified = false
    @semaphore = Mutex.new
  end

  def pick_up
    @semaphore.synchronize do
      item = @contents
      @contents = nil
      @modified = true

      item
    end
  end

  def put_down(item)
    @semaphore.synchronize do
      raise SlotFull, 'slot already full' if @contents
      raise SlotModified, 'slot already modified' if @modified

      @modified = true
      @contents = item
    end
  end

  def peek_at
    @contents
  end

  def reset
    @modified = false
  end
end

require 'ffi'

require 'csv'

module Keyboard
  extend FFI::Library
  ffi_lib 'user32'
  
  # Define functions for key press
  attach_function :keybd_event, [:uchar, :uchar, :uint, :pointer], :void

  # Virtual key codes for movement (adjust as needed)
  LEFT = 0x25
  RIGHT = 0x27
  UP = 0x26
  DOWN = 0x28

  def self.press_key(key)
    keybd_event(key, 0, 0, nil)  # Press key
    sleep(0.05)                  # Hold for stability
    keybd_event(key, 0, 2, nil)  # Release key
  end
end

# Example AI movement
def ai_move
  Keyboard.press_key(Keyboard::RIGHT)  # Move right
  Keyboard.press_key(Keyboard::UP)     # Move up
end


# Open CSV for logging
CSV.open("game_log.csv", "a") do |csv|
  csv << ["timestamp", "x", "y", "event", "score", "lives"]
end

def log_event(event, score, lives)
  CSV.open("game_log.csv", "a") do |csv|
    csv << [Time.now.to_f, turtle.x, turtle.y, event, score, lives]
  end
end

# Detect collisions & log
if turtle_touches_collectible?
  log_event("collected_#{collectible.color}", score, lives)
elsif turtle_touches_brown?
  log_event("brown_collision", score, lives)
end

loop do
    collectibles = get_collectibles()  # Fetch collectible positions
    brown_objects = get_brown_objects()
  
    if collectibles.any?
      target = collectibles.min_by { |c| distance(turtle.x, turtle.y, c.x, c.y) }
      move_toward(target.x, target.y)
    else
      avoid_brown(brown_objects)
    end
  
    sleep(0.1)  # Adjust for game speed
  end
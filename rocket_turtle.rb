#!/usr/bin/env ruby
require 'ruby2d'
require_relative 'keypress' # Load AI keypress handling
require 'csv'

# Window settings
set title: "Rocket Turtle", width: 800, height: 600, background: 'white'

# Define max size constraints
MAX_WIDTH = Window.width - 10  
MAX_HEIGHT = Window.height - 10
TURTLE_COLLISION_SIZE = 40     
SPEED = 8 # Increased speed
score = 0
pause = true

# High score tracking
HIGHSCORE_FILE = "highscores.txt"
$highest_score = 0

# Open CSV for logging
unless File.exist?("game_log.csv")
  CSV.open("game_log.csv", "a") do |csv|
    csv << ["timestamp", "x", "y", "event", "score", "poops"]
  end
end

# logging scores and moves
def log_event(event, score, poops, turtle)
  CSV.open("game_log.csv", "a") do |csv|
    csv << [Time.now.to_f, turtle.x, turtle.y, event, score, poops]
  end
end

# Available movement keys
MOVEMENT_KEYS = [:left, :right, :up, :down]

# Load highest score from file
if File.exist?(HIGHSCORE_FILE)
  scores = File.readlines(HIGHSCORE_FILE).map(&:to_i)
  $highest_score = scores.max unless scores.empty?
end

# Global variables for collectible rules
$black_spawned = false         
$brown_collision_count = 0     

# Score display
keepscore = Text.new(score, x: 50, y: 50, size: 40, color: 'green')
highscore_text = Text.new("High Score: #{$highest_score}", x: 600, y: 50, size: 20, color: 'blue')

# Global variables for collectible rules
$black_spawned = false         # Only allow one black collectible
$brown_collision_count = 0     # Count brown collisions

# ----------------------------
# Direction tracking
$direction = 'up'  

# ----------------------------
# Create a collision box for the turtle.
# This box will move with the rocket turtle and be used for collision detection.
turtle = Rectangle.new(
  x: Window.width / 2.0 - TURTLE_COLLISION_SIZE / 2.0,
  y: Window.height / 2.0 - TURTLE_COLLISION_SIZE / 2.0,
  width: TURTLE_COLLISION_SIZE,
  height: TURTLE_COLLISION_SIZE,
  color: [0, 0, 0, 0]   # Fully transparent collision box
)

# We'll store our decorative turtle shapes here so we can update them each frame.
$turtle_decorations = []



# Draw the decorative rocket turtle relative to the given center point.
def draw_turtle_decorations(cx, cy, direction)
  # Remove previous decorations to reduce flicker
  $turtle_decorations.each(&:remove)
  $turtle_decorations.clear

  # --- Turtle Shell Pattern ---
  shell_size = 40  # Reduced size for consistency with collision box
  shell_x = cx - shell_size / 2.0
  shell_y = cy - shell_size / 2.0

  # Base green shell
  $turtle_decorations << Square.new(
    x: shell_x,
    y: shell_y,
    size: shell_size,
    color: 'green'
  )

  # Central yellow square for pattern detail
  central_size = 16
  central_x = cx - central_size / 2.0
  central_y = cy - central_size / 2.0
  $turtle_decorations << Square.new(
    x: central_x,
    y: central_y,
    size: central_size,
    color: 'yellow'
  )

  # Top-left triangle of the pattern
  $turtle_decorations << Triangle.new(
    x1: shell_x, y1: shell_y,
    x2: cx,    y2: central_y,
    x3: central_x, y3: central_y + central_size / 2.0,
    color: 'yellow'
  )

  # Top-right triangle of the pattern
  $turtle_decorations << Triangle.new(
    x1: shell_x + shell_size, y1: shell_y,
    x2: cx,                   y2: central_y,
    x3: central_x + central_size, y3: central_y + central_size / 2.0,
    color: 'yellow'
  )

  # Bottom-left triangle of the pattern
  $turtle_decorations << Triangle.new(
    x1: shell_x, y1: shell_y + shell_size,
    x2: central_x, y2: central_y + central_size / 2.0,
    x3: cx,      y3: central_y + central_size,
    color: 'yellow'
  )

  # Bottom-right triangle of the pattern
  $turtle_decorations << Triangle.new(
    x1: shell_x + shell_size, y1: shell_y + shell_size,
    x2: central_x + central_size, y2: central_y + central_size / 2.0,
    x3: cx, y3: central_y + central_size,
    color: 'yellow'
  )

  # --- Turtle Neck and Head Adjusted Based on Direction ---
  head_radius = 10
  #neck_x, neck_y, head_x, head_y = cx, cy, cx, cy

  case direction
  when 'up'
    neck_width = 12
    neck_height = 20
    neck_x = cx - neck_width / 2.0
    neck_y = shell_y - neck_height
    head_x = cx
    head_y = neck_y - head_radius
  when 'down'
    neck_width = 12
    neck_height = 20
    neck_x = cx - neck_width / 2.0
    neck_y = shell_y + shell_size
    head_x = cx
    head_y = neck_y + head_radius + neck_height
  when 'left'
    neck_width = 20
    neck_height = 12
    neck_x = shell_x - neck_width
    neck_y = cy - neck_height / 2.0
    head_x = neck_x - head_radius
    head_y = cy
  when 'right'
    neck_width = 20
    neck_height = 12
    neck_x = shell_x + shell_size
    neck_y = cy - neck_height / 2.0
    head_x = neck_x + neck_height + ( head_radius * 2 )
    head_y = cy
  end

  $turtle_decorations << Rectangle.new(x: neck_x, y: neck_y, width: neck_width, height: neck_height, color: 'green')
  $turtle_decorations << Circle.new(x: head_x, y: head_y, radius: head_radius, color: 'green')

end


# ----------------------------
# Handle Movement & Pause Toggle
on :key_held do |event|
  next if pause
  
  case event.key
  when 'up'
    turtle.y -= SPEED if turtle.y > 0
    $direction = 'up'
    log_event("keypress_#{$direction}", score, $brown_collision_count, turtle)
  when 'down'
    turtle.y += SPEED if turtle.y + turtle.height < MAX_HEIGHT
    $direction = 'down'
    log_event("keypress_#{$direction}", score, $brown_collision_count, turtle)
  when 'left'
    turtle.x -= SPEED if turtle.x > 0
    $direction = 'left'
    log_event("keypress_#{$direction}", score, $brown_collision_count, turtle)
  when 'right'
    turtle.x += SPEED if turtle.x + turtle.width < MAX_WIDTH
    $direction = 'right'
    log_event("keypress_#{$direction}", score, $brown_collision_count, turtle)
  end
end

on :key_down do |event|
  case event.key
  when 'space'
    pause = false
    [Rednew, Blacknew, Brownnew, Purplenew, Yellownew, Spacenew].each(&:remove)
  when 'escape'
    File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
    close
  end
end

# ----------------------------
# Display scoring instructions
Rednew = Text.new("Red (Apple) → 100", x: 100, y: 140, size: 20, color: 'red')
Yellownew = Text.new("Yellow (Banana) → 500", x: 100, y: 170, size: 20, color: 'yellow')
Brownnew = Text.new("Brown (Poop) [max 10]", x: 100, y: 200, size: 20, color: 'brown')
Purplenew = Text.new("Purple (Pizza) → 1000", x: 100, y: 230, size: 20, color: 'purple')
Blacknew = Text.new("Black → Ends game (only 1)", x: 100, y: 260, size: 20, color: 'black')
Spacenew = Text.new("Press Space to Start game", x: 100, y: 550, size: 40, color: 'green')

# ----------------------------
# Movement speed (pixels per frame)
# speed = 5 # Removed redundant variable

# Array to hold collectible objects and spawn timer setup
collectibles = []
last_spawn_time = Time.now
spawn_interval = 5.0 # Start at 5 seconds, decrease over time
min_spawn_interval = 1.0 # Minimum interval of 1 second
spawn_decrease_rate = 0.1 # Decrease spawn time every spawn cycle
object_size = 20

# Helper method to normalize colors (rounding to 1 decimal place)
def normalize_color(color)
  color.to_a.map { |v| v.round(1) } # Round each RGBA value to avoid precision mismatches
end

# Predefined object colors (normalized for comparison) - Made global
$object_colors = {
  'red'    => normalize_color(Color.new('red')),    # [1.0, 0.0, 0.0, 1.0]
  'yellow' => normalize_color(Color.new('yellow')), # [1.0, 1.0, 0.0, 1.0]
  'brown'  => normalize_color(Color.new([0.4, 0.2, 0.0, 1.0])),
  'purple' => normalize_color(Color.new([0.7, 0.1, 0.8, 1.0])),
  'black'  => normalize_color(Color.new([0.1, 0.1, 0.1, 1.0]))
}

# Helper method to check if a position is valid (not overlapping with turtle or existing objects)
def valid_position?(x, y, size, turtle, collectibles)
  # Check if the position overlaps with the turtle
  return false if x < turtle.x + turtle.width &&
                  x + size > turtle.x &&
                  y < turtle.y + turtle.height &&
                  y + size > turtle.y

  # Check if the position overlaps with any existing objects
  collectibles.each do |obj|
    next if obj.nil? || obj.x.nil? || obj.y.nil?  # Skip nil objects

    obj_width = obj.is_a?(Circle) ? obj.radius * 2 : (obj.respond_to?(:width) ? obj.width : nil)
    obj_height = obj.is_a?(Circle) ? obj.radius * 2 : (obj.respond_to?(:height) ? obj.height : nil)
    obj_x = obj.is_a?(Circle) ? obj.x - obj.radius : obj.x
    obj_y = obj.is_a?(Circle) ? obj.y - obj.radius : obj.y

    next if obj_x.nil? || obj_y.nil? || obj_width.nil? || obj_height.nil?  # Skip invalid objects

    return false if x < obj_x + obj_width &&
                    x + size > obj_x &&
                    y < obj_y + obj_height &&
                    y + size > obj_y
  end

  true
end

# Global variable to track the AI movement thread
$ai_thread = nil

# ----------------------------
# Update loop: collectible spawning, collision detection, update turtle decorations.
update do
  unless pause
    # --- Update turtle decorations based on the collision box's center ---
    turtle_center_x = turtle.x + turtle.width / 2.0
    turtle_center_y = turtle.y + turtle.height / 2.0
    draw_turtle_decorations(turtle_center_x, turtle_center_y, $direction)
    # ----------------------------
    # Update loop: Redraw turtle with correct direction
    #  draw_turtle_decorations(turtle.x + turtle.width / 2.0, turtle.y + turtle.height / 2.0, $direction)

    # --- Spawn collectibles ---
    if Time.now - last_spawn_time >= spawn_interval
      color = ['red', 'yellow', 'brown', 'purple', 'black'].sample

      # Allow one black collectible only
      if color == 'black' && $black_spawned
        color = ['red', 'yellow', 'brown', 'purple'].sample
      end

      # Only allow 10 brown objects
      brown_count = collectibles.count { |obj| obj.color == 'brown' }
      if color == 'brown' && brown_count >= 10
        color = ['red', 'yellow', 'purple'].sample
      end

      # Find a valid position for the new object
      x_pos, y_pos = nil, nil
      loop do
        x_pos = rand(0..(Window.width - object_size))
        y_pos = rand(0..(Window.height - object_size))
        break if valid_position?(x_pos, y_pos, object_size, turtle, collectibles)
      end

      new_object = case color
        when 'red'
          Circle.new(x: x_pos, y: y_pos, radius: object_size / 2, color: 'red')
        when 'yellow'
          Rectangle.new(x: x_pos, y: y_pos, width: object_size, height: object_size * 2, color: 'yellow')
        when 'brown'
          Square.new(x: x_pos, y: y_pos, size: object_size, color: 'brown')
        when 'purple'
          Triangle.new(
            x1: x_pos, y1: y_pos,
            x2: x_pos + object_size, y2: y_pos,
            x3: x_pos + (object_size / 2), y3: y_pos - object_size,
            color: 'purple'
          )
        when 'black'
          $black_spawned = true
          Rectangle.new(x: x_pos, y: y_pos, width: object_size * 1.5, height: object_size * 1.5, color: 'black')
        else
          nil
      end

      collectibles.push(new_object) if new_object
      last_spawn_time = Time.now
      spawn_interval = [spawn_interval - spawn_decrease_rate, min_spawn_interval].max
    end

    # --- Collision detection between the turtle collision box and collectibles ---
    collectibles.dup.each do |obj|
      # Determine object's bounding box based on its type:
      if obj.is_a?(Circle)
        obj_width = obj.radius * 2
        obj_height = obj.radius * 2
        obj_x = obj.x - obj.radius
        obj_y = obj.y - obj.radius
      elsif obj.is_a?(Triangle)
        min_x = [obj.x1, obj.x2, obj.x3].min
        max_x = [obj.x1, obj.x2, obj.x3].max
        min_y = [obj.y1, obj.y2, obj.y3].min
        max_y = [obj.y1, obj.y2, obj.y3].max
        obj_width = max_x - min_x
        obj_height = max_y - min_y
        obj_x = min_x
        obj_y = min_y
      elsif obj.is_a?(Rectangle)
        obj_width = obj.width
        obj_height = obj.height
        obj_x = obj.x
        obj_y = obj.y
      else
        next
      end

      # Bounding-box collision check
      if turtle.x < obj_x + obj_width &&
        turtle.x + turtle.width > obj_x &&
        turtle.y < obj_y + obj_height &&
        turtle.y + turtle.height > obj_y

        # Collision detected: handle based on object color
        checkcol = normalize_color(obj.color)
        case checkcol 
        when object_colors['red']
          score +=100
          obj.remove # Brown objects never disappear
          log_event("collected_#{checkcol}", score, $brown_collision_count, turtle)
          collectibles.delete(obj)
        when object_colors['yellow']
          score +=500
          obj.remove # Brown objects never disappear
          log_event("collected_#{checkcol}", score, $brown_collision_count, turtle)
          collectibles.delete(obj)
        when object_colors['purple']
          score +=1000
          obj.remove # Brown objects never disappear
          log_event("collected_#{checkcol}", score, $brown_collision_count, turtle)
          collectibles.delete(obj)
        when object_colors['brown']
          $brown_collision_count += 1
          Text.new("Poop!", x: 20 + ($brown_collision_count * 40), y: 20, size: 20, color: 'brown')
          obj.remove # Brown objects never disappear (except the first two poops)
          log_event("collected_#{checkcol}", score, $brown_collision_count, turtle)
          if $brown_collision_count >= 3
            Text.new("GROSS", x: 200, y: 250, size: 40, color: 'red')
            File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
            close
          end
        when object_colors['black']
          log_event("collected_#{checkcol}", score, $brown_collision_count, turtle)
          Text.new("GAME OVER!", x: 200, y: 250, size: 40, color: 'red')
          sleep(2)
          File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
          close
        end
        # Exit loop after processing a single hit to prevent multiple score increments
        break
      end
    end

    # Ensure only one AI movement thread is running
    if $ai_thread.nil? || !$ai_thread.alive?
      $ai_thread = Thread.new do
        # Wait until the game is unpaused before starting AI movement
        while pause
          sleep(0.1) # Check periodically if the game has started
        end
        # Original sleep(3) removed as the loop above handles waiting

        loop do
          target_obj = find_nearest_object(turtle, collectibles)
          chosen_move = nil

          if target_obj && target_obj.respond_to?(:x) && target_obj.x && target_obj.respond_to?(:y) && target_obj.y
            # Capture coordinates immediately
            target_x = target_obj.x
            target_y = target_obj.y

            # Get safe moves
            safe_moves = avoid_dangerous_paths(turtle, collectibles)

            # Determine ideal moves towards the target coordinates
            ideal_moves = []
            ideal_moves << :right if target_x > turtle.x
            ideal_moves << :left if target_x < turtle.x
            ideal_moves << :down if target_y > turtle.y
            ideal_moves << :up if target_y < turtle.y

            # Find the best move: prefer ideal moves if they are safe
            ideal_moves.shuffle.each do |ideal|
              if safe_moves.include?(ideal)
                chosen_move = ideal
                break
              end
            end

            # If no ideal move is safe, pick any safe move that makes progress
            if chosen_move.nil? && !safe_moves.empty?
               preferred_safe_moves = safe_moves.select do |safe_move|
                 (safe_move == :right && target_x > turtle.x) ||
                 (safe_move == :left && target_x < turtle.x) ||
                 (safe_move == :down && target_y > turtle.y) ||
                 (safe_move == :up && target_y < turtle.y)
               end
               chosen_move = preferred_safe_moves.sample || safe_moves.sample
            end

            # If NO moves are safe, let's not move randomly for now.
            # chosen_move ||= MOVEMENT_KEYS.sample if safe_moves.empty? && !ideal_moves.empty?

          else
            # No valid target found. AI does nothing this tick.
          end

          # --- Direct Movement Update ---
          if chosen_move
            case chosen_move
            when :up
              turtle.y -= SPEED if turtle.y > 0
              $direction = 'up'
            when :down
              turtle.y += SPEED if turtle.y + turtle.height < MAX_HEIGHT
              $direction = 'down'
            when :left
              turtle.x -= SPEED if turtle.x > 0
              $direction = 'left'
            when :right
              turtle.x += SPEED if turtle.x + turtle.width < MAX_WIDTH
              $direction = 'right'
            end
            # Optional logging:
            # log_event("ai_move_#{chosen_move}", score, $brown_collision_count, turtle)
          end
          # --- End Direct Movement Update ---

          sleep(0.1) # AI think/move interval
        end
      end
    end

    # Update score display
    keepscore.remove
    keepscore = Text.new(score, x: 50, y: 50, size: 40, color: 'green')

    # Update high score if the current score is greater
    if score > $highest_score
      $highest_score = score
      highscore_text.remove
      highscore_text = Text.new("High Score: #{$highest_score}", x: 600, y: 50, size: 20, color: 'blue')
    end

    # --- Prevent Immediate Triple Poop Hit ---
    #if $brown_collision_count > 0
    #  sleep(0.2)  # Small delay to prevent multiple quick detections
    #end

    # --- Fix Poop Collision Delay ---
    if $poop_hit_recently
      $poop_hit_recently = false  # Reset flag
    end

    # ----------------------------
    # Poop Collision Detection Fix
    if $poop_hit_recently == false
      # Simulate checking for collision with brown (poop) objects
      if some_collision_with_poop  # Replace with actual collision detection logic
        $brown_collision_count += 1
        Text.new("Poop!", x: 20 + ($brown_collision_count * 40), y: 20, size: 20, color: 'brown')

        if $brown_collision_count >= 3
          Text.new("GROSS", x: 200, y: 250, size: 40, color: 'red')
          sleep(2)
          File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
          close
        end

        $poop_hit_recently = true  # Set flag so sleep(0.2) only happens once per poop hit
        sleep(0.2)  # Apply delay only for the first hit, not every update
      end
    end
  end
end

# Helper method to calculate distance between two objects (moved from AI loop)
def distance(obj1, obj2)
  # Use center points for more accurate distance, especially for rectangles/triangles
  c1x = obj1.x + (obj1.respond_to?(:width) ? obj1.width / 2.0 : 0)
  c1y = obj1.y + (obj1.respond_to?(:height) ? obj1.height / 2.0 : 0)
  c2x = obj2.x + (obj2.respond_to?(:width) ? obj2.width / 2.0 : 0)
  c2y = obj2.y + (obj2.respond_to?(:height) ? obj2.height / 2.0 : 0)

  # Handle potential nil coordinates if an object was removed mid-calculation
  return Float::INFINITY if c1x.nil? || c1y.nil? || c2x.nil? || c2y.nil?

  Math.sqrt((c1x - c2x)**2 + (c1y - c2y)**2)
end

# Helper method to calculate distance between two objects
def distance(obj1, obj2)
  # Use center points for more accurate distance, especially for rectangles/triangles
  # Handle potential nil objects or coordinates if removed mid-calculation
  return Float::INFINITY unless obj1 && obj1.respond_to?(:x) && obj1.x && obj1.respond_to?(:y) && obj1.y
  return Float::INFINITY unless obj2 && obj2.respond_to?(:x) && obj2.x && obj2.respond_to?(:y) && obj2.y

  c1x = obj1.x + (obj1.respond_to?(:width) ? obj1.width / 2.0 : 0)
  c1y = obj1.y + (obj1.respond_to?(:height) ? obj1.height / 2.0 : 0)
  c2x = obj2.x + (obj2.respond_to?(:width) ? obj2.width / 2.0 : 0)
  c2y = obj2.y + (obj2.respond_to?(:height) ? obj2.height / 2.0 : 0)

  Math.sqrt((c1x - c2x)**2 + (c1y - c2y)**2)
end

# Helper method to find the nearest object
def find_nearest_object(turtle, collectibles)
  # Exclude dangerous objects (brown poop, black holes)
  safe_collectibles = collectibles.reject do |obj|
    next true if obj.nil? # Skip nil objects just in case
    normalized_color = normalize_color(obj.color)
    normalized_color == $object_colors['brown'] || normalized_color == $object_colors['black'] # Use global variable
  end

  return nil if safe_collectibles.empty? # No safe objects available

  # Prioritize by score (Purple > Yellow > Red), then by distance (closer is better)
  best_object = safe_collectibles.sort_by do |obj|
    score_value = case normalize_color(obj.color)
                  when $object_colors['purple'] then 3 # Highest score
                  when $object_colors['yellow'] then 2 # Medium score
                  when $object_colors['red']    then 1 # Lowest score
                  else 0
                  end
    # Sort descending by score (-score_value), then ascending by distance
    [-score_value, distance(turtle, obj)]
  end.first # Get the best one after sorting

  best_object
end

# Removed ai_move_toward function as logic is now directly in the AI thread loop


# Determines a safe direction for the turtle to move, avoiding dangerous paths.
#
# @param turtle [Turtle] the turtle object that needs to move
# @param collectibles [Array<Collectible>] an array of collectible objects on the map
# @return [Array<Symbol>] a list of safe directions for the turtle to move
#
# The method identifies dangerous zones based on the color of the collectibles (brown or black).
# It then checks each possible movement direction to see if the new position would be within 20 units
# of any dangerous collectible. If a safe direction is found, it is returned. If no safe direction is found,
# the method returns nil, indicating that the AI may stop or choose a random movement.
def avoid_dangerous_paths(turtle, collectibles)
  # Identify dangerous objects
  danger_zone = collectibles.reject { |obj| obj.nil? }.select do |obj|
     normalized_color = normalize_color(obj.color)
     normalized_color == $object_colors['brown'] || normalized_color == $object_colors['black'] # Use global variable
  end

  return MOVEMENT_KEYS if danger_zone.empty? # All moves are safe if no danger nearby

  safe_directions = []
  safety_margin = TURTLE_COLLISION_SIZE + 5 # Check slightly beyond collision box

  MOVEMENT_KEYS.each do |direction|
    new_x, new_y = future_position(turtle, direction)
    is_safe = true

    # Check if the potential new position is too close to any dangerous object
    danger_zone.each do |danger_obj|
      # Calculate danger object's center for distance check
      danger_cx = danger_obj.x + (danger_obj.respond_to?(:width) ? danger_obj.width / 2.0 : (danger_obj.respond_to?(:radius) ? 0 : 0))
      danger_cy = danger_obj.y + (danger_obj.respond_to?(:height) ? danger_obj.height / 2.0 : (danger_obj.respond_to?(:radius) ? 0 : 0))

      # Check distance from turtle's future center to danger's center
      future_turtle_cx = new_x + turtle.width / 2.0
      future_turtle_cy = new_y + turtle.height / 2.0

      # A simple bounding box check might be sufficient and less complex here
      # Check if future turtle bounding box overlaps danger bounding box + margin
      danger_x_min = danger_obj.x - safety_margin
      danger_x_max = danger_obj.x + (danger_obj.respond_to?(:width) ? danger_obj.width : (danger_obj.respond_to?(:radius) ? danger_obj.radius*2 : 0)) + safety_margin
      danger_y_min = danger_obj.y - safety_margin
      danger_y_max = danger_obj.y + (danger_obj.respond_to?(:height) ? danger_obj.height : (danger_obj.respond_to?(:radius) ? danger_obj.radius*2 : 0)) + safety_margin

      future_turtle_x_min = new_x
      future_turtle_x_max = new_x + turtle.width
      future_turtle_y_min = new_y
      future_turtle_y_max = new_y + turtle.height

      if future_turtle_x_max > danger_x_min && future_turtle_x_min < danger_x_max &&
         future_turtle_y_max > danger_y_min && future_turtle_y_min < danger_y_max
        is_safe = false
        break # No need to check other dangers for this direction
      end
    end

    safe_directions << direction if is_safe
  end

  safe_directions # Return list of all safe directions
end

# Helper function to simulate turtle's future position based on key press
def future_position(turtle, direction)
  case direction
  when :left  then [turtle.x - SPEED, turtle.y] # Use SPEED constant
  when :right then [turtle.x + SPEED, turtle.y] # Use SPEED constant
  when :up    then [turtle.x, turtle.y - SPEED] # Use SPEED constant
  when :down  then [turtle.x, turtle.y + SPEED] # Use SPEED constant
  end
end

# Removed duplicate distance function (defined earlier near line 419)

# def update_ai_targets(turtle, collectibles)
#   # Filter collectibles to include only fruits (red, yellow) and pizza (purple)
#   valid_collectibles = collectibles.select do |obj|
#     normalized_color = normalize_color(obj[:object].color)
#     is_valid = [$object_colors['red'], $object_colors['yellow'], $object_colors['purple']].include?(normalized_color)
#     log_event("filtering_collectible", 0, 0, obj[:object]) unless is_valid # Log excluded collectibles
#     is_valid
#   end
#
#   # Log valid collectibles
#   valid_collectibles.each do |obj|
#     log_event("valid_collectible", 0, 0, obj[:object])
#   end
#
#   # Use turtle's center for accurate distance calculation
#   turtle_center_x = turtle.x + turtle.width / 2.0
#   turtle_center_y = turtle.y + turtle.height / 2.0
#
#   # Sort collectibles by score (descending) and then by distance (ascending)
#   sorted_collectibles = valid_collectibles.sort_by do |obj|
#     next Float::INFINITY if obj[:object].nil? # Skip invalid objects
#
#     if obj[:object].is_a?(Triangle)
#       # Calculate the center of the triangle as the average of its vertices
#       obj_center_x = (obj[:object].x1 + obj[:object].x2 + obj[:object].x3) / 3.0
#       obj_center_y = (obj[:object].y1 + obj[:object].y2 + obj[:object].y3) / 3.0
#     else
#       # For other shapes, calculate the center based on their dimensions
#       obj_center_x = obj[:x] + (obj[:object].is_a?(Circle) ? obj[:object].radius : obj[:object].width / 2.0)
#       obj_center_y = obj[:y] + (obj[:object].is_a?(Circle) ? obj[:object].radius : obj[:object].height / 2.0)
#     end
#
#     # Sort by score (descending) and distance (ascending)
#     [-obj[:score], Math.sqrt((obj_center_x - turtle_center_x)**2 + (obj_center_y - turtle_center_y)**2)]
#   end
#
#   # Update the global target list
#   $ai_targets = sorted_collectibles
# end
# Commented out unused function

show
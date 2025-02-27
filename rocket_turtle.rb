#!/usr/bin/env ruby
require 'ruby2d'

# Window settings
set title: "Rocket Turtle", width: 800, height: 600, background: 'white'

# Define max size constraints
MAX_WIDTH = Window.width - 10  
MAX_HEIGHT = Window.height - 10
TURTLE_COLLISION_SIZE = 40     
SPEED = 5
score = 0
pause = true

# High score tracking
HIGHSCORE_FILE = "highscores.txt"
$highest_score = 0

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
  neck_width = 8
  neck_height = 12
  head_radius = 6
  neck_x, neck_y, head_x, head_y = cx, cy, cx, cy

  case direction
  when :up
    neck_x = cx - neck_width / 2.0
    neck_y = shell_y - neck_height
    head_x = cx
    head_y = neck_y - head_radius
  when :down
    neck_x = cx - neck_width / 2.0
    neck_y = shell_y + shell_size
    head_x = cx
    head_y = neck_y + head_radius
  when :left
    neck_x = shell_x - neck_height
    neck_y = cy - neck_width / 2.0
    head_x = neck_x - head_radius
    head_y = cy
  when :right
    neck_x = shell_x + shell_size
    neck_y = cy - neck_width / 2.0
    head_x = neck_x + head_radius
    head_y = cy
  end

  $turtle_decorations << Rectangle.new(x: neck_x, y: neck_y, width: neck_width, height: neck_height, color: 'green')
  $turtle_decorations << Circle.new(x: head_x, y: head_y, radius: head_radius, color: 'green')

end

# ----------------------------
# Direction tracking for movement
direction = :up  

on :key_held do |event|
  case event.key
  when 'up'
    turtle.y -= SPEED if turtle.y > 0
    direction = :up
  when 'down'
    turtle.y += SPEED if turtle.y + turtle.height < MAX_HEIGHT
    direction = :down
  when 'left'
    turtle.x -= SPEED if turtle.x > 0
    direction = :left
  when 'right'
    turtle.x += SPEED if turtle.x + turtle.width < MAX_WIDTH
    direction = :right
  when 'escape'
    File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
    close
  when 'space'
    # Clear instructions when space key is pressed
    Rednew.remove
    Blacknew.remove
    Brownnew.remove
    Purplenew.remove
    Yellownew.remove
    Spacenew.remove
    pause = false
  end
end

# ----------------------------
# Display scoring instructions
Rednew = Text.new("Red (Apple) → 100", x: 100, y: 140, size: 20, color: 'red')
Yellownew = Text.new("Yellow (Banana) → 500", x: 100, y: 170, size: 20, color: 'yellow')
Brownnew = Text.new("Brown (Poop) [max 10]", x: 100, y: 200, size: 20, color: 'brown')
Purplenew = Text.new("Purple (Pizza) → 1000", x: 100, y: 230, size: 20, color: 'purple')
Blacknew = Text.new("Black → Ends game (only 1)", x: 100, y: 260, size: 20, color: 'black')
Spacenew = Text.new("Space to Start game", x: 100, y: 290, size: 20, color: 'black')

# ----------------------------
# Movement speed (pixels per frame)
speed = 5

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

# Predefined object colors (normalized for comparison)
object_colors = {
  'red'    => normalize_color(Color.new('red')),    # [1.0, 0.0, 0.0, 1.0]
  'yellow' => normalize_color(Color.new('yellow')), # [1.0, 1.0, 0.0, 1.0]
  'brown'  => normalize_color(Color.new([0.4, 0.2, 0.0, 1.0])), 
  'purple' => normalize_color(Color.new([0.7, 0.1, 0.8, 1.0])), 
  'black'  => normalize_color(Color.new([0.1, 0.1, 0.1, 1.0])) 
}

# ----------------------------
# Update loop: collectible spawning, collision detection, update turtle decorations.
update do; unless pause
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

    x_pos = rand(0..(Window.width - object_size))
    y_pos = rand(0..(Window.height - object_size))

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
        collectibles.delete(obj)
      when object_colors['yellow']
        score +=500
        obj.remove # Brown objects never disappear
        collectibles.delete(obj)
      when object_colors['purple']
        score +=1000
        obj.remove # Brown objects never disappear
        collectibles.delete(obj)
      when object_colors['brown']
        $brown_collision_count += 1
        Text.new("Poop!", x: 20 + ($brown_collision_count * 40), y: 20, size: 20, color: 'brown')
        obj.remove # Brown objects never disappear (except the first two poops)
        if $brown_collision_count >= 3
          Text.new("GROSS", x: 200, y: 250, size: 40, color: 'red')
          File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
          close
        end
      when object_colors['black']
        Text.new("GAME OVER!", x: 200, y: 250, size: 40, color: 'red')
        sleep(2)
        File.open(HIGHSCORE_FILE, "a") { |file| file.puts score }
        close
      end
      # Exit loop after processing a single hit to prevent multiple score increments
      break
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
end
end

show
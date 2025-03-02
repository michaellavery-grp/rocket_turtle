#!/usr/bin/env ruby
require 'ruby2d'

# Window settings
set title: "Rocket Turtle", width: 800, height: 600, background: 'white'

# Define max size constraints
MAX_WIDTH = Window.width - 10  
MAX_HEIGHT = Window.height - 10
TURTLE_COLLISION_SIZE = 80   
SPEED = 5
score = 0
pause = true

# High score tracking
HIGHSCORE_FILE = "highscores.txt"
$highest_score = 0

if File.exist?(HIGHSCORE_FILE)
  scores = File.readlines(HIGHSCORE_FILE).map(&:to_i)
  $highest_score = scores.max unless scores.empty?
end

# Global collectible rules
$black_spawned = false         
$brown_collision_count = 0     
$poop_hit_recently = false     # Prevent multiple immediate poop hits

# Score display
keepscore = Text.new(score, x: 50, y: 50, size: 40, color: 'green')
highscore_text = Text.new("High Score: #{$highest_score}", x: 600, y: 50, size: 20, color: 'blue')

# ----------------------------
# Direction tracking
$direction = :up  

# ----------------------------
# Create a collision box for the turtle.
turtle = Rectangle.new(
  x: Window.width / 2.0 - TURTLE_COLLISION_SIZE / 2.0,
  y: Window.height / 2.0 - TURTLE_COLLISION_SIZE / 2.0,
  width: TURTLE_COLLISION_SIZE,
  height: TURTLE_COLLISION_SIZE,
  color: [0, 0, 0, 0]  
)

# Decorative turtle
$turtle_decorations = []

# ----------------------------
# Draw Rocket Turtle with Correct Direction
def draw_turtle_decorations(cx, cy, direction)
  $turtle_decorations.each(&:remove)
  $turtle_decorations.clear

  shell_size = TURTLE_COLLISION_SIZE
  shell_x = cx - shell_size / 2.0
  shell_y = cy - shell_size / 2.0

  $turtle_decorations << Square.new(x: shell_x, y: shell_y, size: shell_size, color: 'green')

  # --- Shell Patches ---
  patch_size = shell_size / 4
  patch_positions = [
    [shell_x + patch_size, shell_y + patch_size],
    [shell_x + 2 * patch_size, shell_y + patch_size],
    [shell_x + patch_size, shell_y + 2 * patch_size],
    [shell_x + 2 * patch_size, shell_y + 2 * patch_size]
  ]
  patch_positions.each do |px, py|
    $turtle_decorations << Square.new(x: px, y: py, size: patch_size, color: 'yellow')
  end

  # --- Turtle Neck and Head ---
  neck_width = 12
  neck_height = 20
  head_radius = 10
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
# Handle Movement & Pause Toggle
on :key_held do |event|
  next if pause

  case event.key
  when 'up'
    turtle.y -= SPEED if turtle.y > 0
    $direction = :up
  when 'down'
    turtle.y += SPEED if turtle.y + turtle.height < MAX_HEIGHT
    $direction = :down
  when 'left'
    turtle.x -= SPEED if turtle.x > 0
    $direction = :left
  when 'right'
    turtle.x += SPEED if turtle.x + turtle.width < MAX_WIDTH
    $direction = :right
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
# Display Instructions Before Start
Rednew = Text.new("Red (Apple) → 100", x: 100, y: 140, size: 20, color: 'red')
Yellownew = Text.new("Yellow (Banana) → 1000", x: 100, y: 170, size: 20, color: 'yellow')
Brownnew = Text.new("Brown (Poop) [max 10]", x: 100, y: 200, size: 20, color: 'brown')
Purplenew = Text.new("Purple (Pizza) → 500", x: 100, y: 230, size: 20, color: 'purple')
Blacknew = Text.new("Black → Ends game (only 1)", x: 100, y: 260, size: 20, color: 'black')
Spacenew = Text.new("Press SPACE to Start", x: 100, y: 290, size: 20, color: 'black')

# ----------------------------
# Update Loop
update do
  next if pause

  draw_turtle_decorations(turtle.x + turtle.width / 2.0, turtle.y + turtle.height / 2.0, $direction)

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

show
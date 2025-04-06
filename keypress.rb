require 'ffi'
require 'ostruct' # Required for OpenStruct

module MacKeyboard
  extend FFI::Library
  ffi_lib '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices'

  # Define functions from Quartz Event Services
  attach_function :CGEventCreateKeyboardEvent, [:pointer, :ushort, :bool], :pointer
  attach_function :CGEventPost, [:uint32, :pointer], :void
  attach_function :CFRelease, [:pointer], :void

  # Constants
  KCGEventTap = 0  # Event Tap
  KCGEventSourceStateHIDSystemState = 1
  KCGSessionEventTap = 1  # Event sent to active session

  # Virtual Key Codes for macOS
  KEY_CODES = {
    left: 0x7B,
    right: 0x7C,
    down: 0x7D,
    up: 0x7E,
    space: 0x31
  }

  # Simulate key press
  def self.press_key(key)
    key_code = KEY_CODES[key]
    return unless key_code

    event_down = CGEventCreateKeyboardEvent(nil, key_code, true)
    event_up = CGEventCreateKeyboardEvent(nil, key_code, false)

    CGEventPost(KCGSessionEventTap, event_down)
    CGEventPost(KCGSessionEventTap, event_up)

    CFRelease(event_down)
    CFRelease(event_up)
  end
end

module Keypress
  def self.simulate(key)
    case key
    when :up
      Window.on(:key_held).call(OpenStruct.new(key: 'up'))
    when :down
      Window.on(:key_held).call(OpenStruct.new(key: 'down'))
    when :left
      Window.on(:key_held).call(OpenStruct.new(key: 'left'))
    when :right
      Window.on(:key_held).call(OpenStruct.new(key: 'right'))
    else
      raise ArgumentError, "Unsupported key: #{key}"
    end
  end
end
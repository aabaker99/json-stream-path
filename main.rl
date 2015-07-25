#!/usr/bin/ragel -R 
require 'json'
require './path'

%%{
  machine json ;

  action a_start_object {
    machine_stack.push(:object)
    obj_stack.push(p)
  }

  action a_end_object {
    # since we must make a machine transition to deal with JSON's recursive structure,
    # we miss the initial "{" so we add it here
    obj_start = obj_stack.pop()
    obj = "{" + data[obj_start..p].pack("c*")
    puts "a_end_object: #{JSON.parse(obj).inspect}"
    puts "a_end_object: machine_stack=#{machine_stack.inspect}"
    machine_stack.pop()
  }

  action a_start_array {
    machine_stack.push(:array)
    array_index = -1
    array_stack.push(p)
  }

  action a_end_array {
    # since we must make a machine transition to deal with JSON's recursive structure,
    # we miss the initial "[" so we add it here
    array_start = array_stack.pop()
    array = "[" + data[array_start..p].pack("c*")
    puts "a_end_array: #{JSON.parse(array).inspect}"
    puts "a_end_array: machine_stack=#{machine_stack.inspect}"
    machine_stack.pop()
  }

  action a_begin_array_value {
    array_index += 1
    puts "a_begin_array_value: array_index=#{array_index.inspect}"
    key_stack.push(array_index.to_s)
    yield_value = yield_value?(parsed_path, key_stack) if(!yield_value)
    if(yield_value and target_state.nil?)
      # then once we return to the current stack state we should yield the value
      target_state = key_stack.dup()
      yield_value_start = p
    end
    puts "a_begin_array_value: key_stack=#{key_stack.inspect}"
  }

  action a_end_array_value {
    puts "a_end_array_value: array_index=#{array_index.inspect}"
    puts "a_end_array_value: key_stack=#{key_stack.inspect} ; target_state=#{target_state.inspect}"
    if(key_stack == target_state)
      target_value = data[yield_value_start..p].pack("c*")
      puts "a_end_array_value: yield_value #{target_value.inspect}"
      yield_value = false
      yield_value_start = nil
      target_state = nil
    end

    key_stack.pop()
  }

  action a_start_key {
    key_start = p + 1 # exclude initial quote mark
  }

  action a_end_key {
    key = data[key_start..p-1].pack("c*") # exclude terminal quote mark
    key_stack.push(key)
    puts "a_end_key: #{p.inspect} #{key.inspect}"
    puts "a_end_key: key_stack: #{key_stack.inspect}"
    
    yield_value = yield_value?(parsed_path, key_stack) if(!yield_value)
    if(yield_value and target_state.nil?)
      # then once we return to the current stack state we should yield the value
      yield_value_start = p
      target_state = key_stack.dup()
    end
    puts "a_end_key: parsed_path=#{parsed_path.inspect}"
    puts "a_end_key: key_stack=#{key_stack.inspect}"
 }

  action a_start_value {
    puts "a_start_value: #{p.inspect}"
    value_stack.push(p+1)
  }

  action a_end_value {
    puts "key_stack=#{key_stack.inspect} ; target_state=#{target_state.inspect}"
    if(key_stack == target_state)
      target_value = data[yield_value_start..p].pack("c*")
      puts "a_end_value: yield_value #{target_value.inspect}"
      yield_value = false
      yield_value_start = nil
      target_state = nil
    end

    value_start = value_stack.pop()
    value = data[value_start..p-1].pack("c*")
    key = key_stack.pop()
  }

  include json "json_events.rl" ;
}%%

%% write data ;

def main(data, path_str)
  # Ragel variabels -{{
  # The write init statement expects a few declared variables:
  # "In Go, Java and Ruby code the data variable must also be declared." p.35
  data = data.unpack("c*") if(data.is_a?(String))

  # parse JSON path for state machine interpretation
  parsed_path = parse_path(path_str)

  # "If stack-based state machine
  # control flow statements are used then the stack and top variables are required." p.35
  stack = []
  top = 0

  p = 0
  pe = p + data.length
  eof = pe
  # }}-

  # this application "globals"
  array_stack = [] # maintain start positions of array
  array_index = -1 # position of last finished value in an array
  obj_stack = [] # maintain start positions of object
  value_stack = [] # maintain start positions of values
  key_stack = [] # strings representing path to current object
  machine_stack = [] # are we in an array or object?
  yield_value = false
  target_state = nil
  yield_value_start = nil

  # sets p, pe, cs, ts, te, act
  %% write init; 
  %% write exec;
end

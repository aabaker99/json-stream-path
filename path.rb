
# Transform a JSONPath into an intermediate form used by this parser 
#   e.g. "$.store.book[2]" -> ["store", "book", "2"]
def parse_path(path)
  # strip root
  path = path.dup()
  path.gsub!("$.", "")

  # treat array access same as object access
  ii = path.index(/\[([^\[]+)\]/)
  if(ii)
    jj = path.index("]", ii)
    path[ii..jj] = ".#{$1.to_i}"
  end
  puts path.inspect

  rv = path.split(".")
  return rv
end

# If the @key_stack@ associated with the current state of the parser
#   matches the desired objects specified by the JSONPath @path@,
#   schedule the object to be yielded to a provided code block
# @todo only works for one type of JSONpath specification
def yield_value?(path, key_stack)
  path == key_stack
end

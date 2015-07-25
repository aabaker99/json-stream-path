require './main.rb'

# Test the compiled Ragel state machine at main.rb against the "example.json" file in this
#   directory
filepath = "./example.json"
io = File.open(filepath)
contents = io.read()
path = "$.store.book[2]"
main(contents, path)
io.close()

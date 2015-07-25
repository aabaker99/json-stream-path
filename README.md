# jsonpath-stream
Low memory parsing of JSON with the JSONPath language

# Usage
This project is still in the prototype stage, but the workflow is

```
# compile the Ragel state machine for the Ruby host language
# creating file main.rb
$ ragel -R main.rl

# run the compiled state machine against the example.json file
$ ruby test.rb > out.txt
```

This produces a bunch of state information on stdout that I've been
using to track the state of the parser; the output lines are all
prefixed with a string associating them with an action function
in main.rl. The most important output line is the one that produces
some serialized JSON associated with the specified JSONPath of 
"$.store.book[2]"

```
$ grep "yield_value" out.txt
# a_end_array_value: yield_value "{ \"category\": \"fiction\",\n        \"author\": \"Herman 
# Melville\",\n        \"title\": \"Moby Dick\",\n        \"isbn\": \"0-553-21311-3\",\n     
# \"price\": 8.99\n      },"
```

I am extending this proof of concept to support the full JSONPath language.

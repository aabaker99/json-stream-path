%%{
  machine json;
  alphtype int;

  # define separate machines to handle JSON's recursive structure
  action return {
    fret ;
  }
  action call_object {
    fcall object ;
  }
  action call_array {
    fcall array ;
  }

  # define the JSON language
  false = 'false' ;
  nul = 'null' ;
  true = 'true' ;

  int = '0' | ([1-9] digit*) ;
  exp = [eE] [\-+]? digit+ ;
  fract = '.' digit+ ;
  number = ('-'? int fract? exp?) ;
  
  ws = [ \t\r\n]*;
  unescaped = 0x20 | 0x21 | (0x23 .. 0x5b) | (0x5d .. 0xffff) ;
  escaped = '\\' (
    '\"' |
    '\\' |
    '/'  |
    'b'  |
    'f'  |
    'n'  |
    'r'  |
    't'  |
    'u' xdigit{4} );
  char = unescaped | escaped;

  string = '"' char* '"' ;
  key = '"' @a_start_key char* '"' @a_end_key ;

  dataValue = false | nul | true | number | string;
  arrayInit = '[' @call_array ;
  objectInit = '{' @call_object ;
  value = dataValue | arrayInit | objectInit ;

  member = key ws ':' ws @a_start_value value %a_end_value ;
  members = member ws (',' ws member ws)* ;
  values = value >a_begin_array_value %a_end_array_value ws (',' ws value >a_begin_array_value %a_end_array_value ws)*;

  object := ( ws members? >a_start_object '}' @a_end_object @return ) ;
  array := ( ws values? >a_start_array ']' @a_end_array @return ) ;
  main := (ws (objectInit | arrayInit)) ws ;
}%%

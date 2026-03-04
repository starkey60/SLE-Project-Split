module DSL_Parsing

import DSL_Grammar;
import ParseTree;
import IO;

start[DSL] parseJSON(str input) {
  return parse(#start[DSL], input);
}

start[DSL] parseFromFile(loc file) {
  str contents = readFile(file);
  return parse(#start[DSL], contents);
}


void testParseFromFile(loc file) {
  str contents = readFile(file);
  println(parseJSON(contents));
}

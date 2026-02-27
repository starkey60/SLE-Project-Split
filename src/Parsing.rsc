module Parsing

import DSL_Grammar;
import ParseTree;
import IO;

start[DSL] parseJSON(str input) {
  return parse(#start[DSL], input);
}

void testParseFromFile(loc file) {
  str contents = readFile(file);
  println(parseJSON(contents));
}

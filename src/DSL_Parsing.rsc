module DSL_Parsing

import DSL_Grammar;
import ParseTree;
import IO;

start[DELTA] parseJSON(str input) {
  return parse(#start[DELTA], input);
}

start[DELTA] parseFromFile(loc file) {
  str contents = readFile(file);
  return parse(#start[DELTA], contents);
}


void testParseFromFile(loc file) {
  str contents = readFile(file);
  println(parseJSON(contents));
}

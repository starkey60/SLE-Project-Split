module backend::codegen::TakeN

import frontend::Grammar;

str generate((Element)`Take <Number n> <Identifier id>`) {
    return "
<id> = <n>
";
}

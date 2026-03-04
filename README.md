# Software Language Engineering project DSL

To test current stage:
1. open a rascal terminal;
2. import testing; (its a short script, making parsing and cstToAst testing easier);
3. call testDSL() with the raascal path of the test file (test.dsl) and an output file for the codegen (test.py). Get them by right clicking on the file using vscode file explorer.
4. To test python code corectness, move generated python code to python_sources and run example_dsl.py, and your generated script. The output should be the same.
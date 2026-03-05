# Software Language Engineering project DSL

To test current stage:
1. open a rascal terminal;
2. import testing; (its a short script, making parsing and cstToAst testing easier);
3. call testDSL() with the raascal path of the test file (test.dsl) and an output file for the codegen (test.py). Get them by right clicking on the file using vscode file explorer.
4. To test python code corectness, move generated python code to python_sources and run example_dsl.py, and your generated script. The output should be the same.

LSP status:
1. open a rascal terminal;
2. import DSL_LSP;
3. run register();
This should result in errors showing when a .dsl file cant be parsed in vscode itself. However, no concrete error messages are shown, nor syntax is highlighted.
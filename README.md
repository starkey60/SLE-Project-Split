# Software Language Engineering project DSL

To test current stage:
1. open a rascal terminal in VS Code (Ctrl+Shift+P -> "Rascal: Create Rascal Terminal");
2. import testing; (its a short script, making parsing and cstToAst testing easier);
3. call testDSL() with the raascal path of the test file and an output file for the codegen. get them by right clicking on the file using vscode file explorer.
    - basic test: testDSL(|file:///path/to/test.dsl|, |file:///path/to/python_sources/test.py|)
    - full cleaning test: testDSL(|file:///path/to/test_cleaning.dsl|, |file:///path/to/python_sources/test_cleaning.py|)
4. install Python dependencies: pip install tabulate matplotlib
5. To test python code corectness, go to python_sources/ and run:
    - python3 example_dsl.py and python3 test.py —> output should match
    - python3 example_cleaning.py and python3 test_cleaning.py -> output should match

note: both test.dsl and test_cleaning.dsl use dropna to handle empty values in data.csv.

LSP status:
1. open a rascal terminal;
2. import DSL_LSP;
3. run register();
This should result in errors showing when a .dsl file cant be parsed in vscode itself. However, no concrete error messages are shown, nor syntax is highlighted.
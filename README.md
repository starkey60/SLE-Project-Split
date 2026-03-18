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
4. check open up `warning_error_test.dsl` to check for errors and warnings showing. You may need to refresh (delete a character and save)

## Warnings And Errors

Warnings:
* **W01**: Dataset \<name\> is already defined
    * Importing a dataset under a name, that is already used for a different dataset. Leads to undefined behaviour
* **W02**: Path \<path\> doesn't end with .csv
    * Providing a path, that does not end with a .csv. May still be a usable dictionary file.

Errors:
* **E01**: Undefined dataset \<name\>
    * Using a dataset under \<name\> that does not exist. Import the dataset using `Load` keyword or double check for typos. 
* **E02**: Cast \<cast\> on \<column\> can only use == or != equality
    * `bool` and `string` casted columns can only use == and != equalities
* **E03**: Value \<value\> is incompatible with cast \<cast\> on \<column\>
    * Type mismatch
* **E04**: Array contains items of different types
    * Heterogeneous arrays are not supported
* **E05**: Cast \<cast\> used on array of type \<type\>
    * Type mismatch
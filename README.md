# Software Language Engineering project DSL

Runinng the pipeline:
0. write your dsl file (or use one of the provided test files)
1. open a rascal terminal in VS Code (Ctrl+Shift+P -> "Rascal: Create Rascal Terminal");
2. import DSL_Main;
3. call main() with the rascal path of the test file. get them by right clicking on the file using vscode file explorer.
4. the generated output will be a python file under the same name and directory as the input file
5. any warnings will be shown in the command line
6. any errors will lead to the python file not being generated
7. install Python dependencies from `python_sources/requirements.txt` (idealy in a venv)
8. run the python script

## Language Server
LSP status:
1. open a rascal terminal;
2. import DSL_LSP;
3. run register();
4. check open up `warning_error_test.dsl` to check for errors and warnings showing. You may need to refresh (delete a character and save)

* **Find references**: `Shift + F12` or right-click -> `Go To References`
* **Find declaration**: `F12` or right-click -> `Go To Definition`
* **Documentation on hover**: hover over a line with your cursor

## Warnings And Errors

Warnings:
* **W01**: Dataset \<name\> is already defined
    * Importing a dataset under a name, that is already used for a different dataset. Leads to undefined behaviour
* **W02**: Path \<path\> doesn't end with .csv
    * Providing a path, that does not end with a .csv. May still be a usable dictionary file.
* **W03**: W03: Renaming to the same name as original
    * Renaming to the same name as original can and should be omitted
* **W04**: It is advised to group transformations on same columns together
    * Keeping transformations grouped by targeted column helps keeping track of the resulting ordering
* **W05**: Redundant keep for column \<col\>
    * Redundant operation, \<col\> will be kept without this operation

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
* **E06**: Agg groupings can only use numeric casts
    * Incorect cast when using GroupBy with an Agg (should be (int) or (float))
* **E07**: E07: Sort requires numeric cast (int or float), got \<cast\> on \<col\>
    * Incorrect cast on sort
    
This should result in errors showing when a .dsl file cant be parsed in vscode itself. However, no concrete error messages are shown, nor syntax is highlighted.

## Unit tests

1. open a rascal terminal;
2. import tests::runner;
3. run :test;

To add new tests, add a testX.rsc where X is the module being tested. To add the new tests to the main runner, add `extend extend tests::testX;` to runner.rsc.

# Software Language Engineering project DSL

Runinng the pipeline:
1. write your dsl file (or use one of the provided test files)
2. open a rascal terminal in VS Code (Ctrl+Shift+P -> "Rascal: Create Rascal Terminal");
3. import DSL_Main;
4. call main() with the rascal path of the test file. get them by right clicking on the file using vscode file explorer.
5. the generated output will be a python file under the same name and directory as the input file
6. any warnings will be shown in the command line
7. any errors will lead to the python file not being generated
8. install Python dependencies from `python_sources/requirements.txt` (idealy in a venv)
9. run the python script

## Runtime
1. Python is required (TODO version requirements?)
2. to install required libraries make a venv: (`python3 -m venv .venv`)
3. Activate venv: `source path-to-venv/bin/activate`
4. Install requiremnts.txt: `pip install -r requirements.txt`

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
    * Providing a path, that does not end with a .csv. It may still be a usable data file.
* **W03**: W03: Renaming to the same name as original
    * Renaming to the same name as original can and should be omitted
* **W04**: Group transformations on the same columns
    * It is advised to group transformations targeting the same column to improve readability and maintain ordering clarity
* **W05**: Redundant keep for column \<col\>
    * Redundant operation, \<col\> will be kept without this operation
* **W06**: Using dataset \'<name>\' after a GroupBy may fail - GroupBy replaces columns
    * GroupBy is a side effectful feature that modifies the dataset in place

Errors:
* **E01**: Undefined dataset \<name\>
    * Using a dataset under \<name\> that does not exist. Import the dataset using `Load` keyword or double check for typos. 
* **E02**: Cast \<cast\> on \<column\> can only use == or != equality
    * `bool` and `string` cast columns can only use == and != equalities
* **E03**: Value \<value\> is incompatible with cast \<cast\> on \<column\>
    * The provided value does not match the expected type.
* **E04**: Array contains items of different types
    * Arrays containing elements of different types are not supported.
* **E05**: Cast \<cast\> used on array of type \<type\>
    * The cast is not compatible with the array's element type.
* **E06**: Agg groupings can only use numeric casts
    * Incorrect cast when using GroupBy with an Agg (should be (int) or (float))
* **E07**: Sort requires numeric cast (int or float), got \<cast\> on \<col\>
    * Sorting requires a numeric cast
    
This should result in errors showing when a .dsl file cant be parsed in vscode itself. However, no concrete error messages are shown, nor syntax is highlighted.

## Unit tests

1. open a rascal terminal;
2. import tests::runner;
3. run :test;

To add new tests, add a testX.rsc where X is the module being tested. To add the new tests to the main runner, add `extend extend tests::testX;` to runner.rsc.

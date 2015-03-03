# union-tool
This script takes two tab delimited files and merge them based on shared column(s).

## Usage
Usage: union.pl --input1=FILENAME  --input2=FILENAME --col1=INT(,INT,INT...) --col2=INT(,INT,INT...) --header=INT --output=FILENAME

  --input1|-1 (FILENAME): name of first input file. Must be a tab delimited file. MANDATORY.
  --input2|-2 (FILENAME): name of second input file. Must be a tab delimited file. MANDATORY.
  --output|-o (FILENAME): name of output file (default STDOUT).
  --col1|-c (List of INT): list of column numbers used to merge the file. (default: 1).
  --col2|-d (List of INT): list of column numbers used to merge the file. (default: 1).
  --header|H (INT): number of header lines. (default: none).

## Goal

This tool makes union of two datasets based on one or many common field.
Columns are referenced with a number. For example, 3 refers to the 3rd column of a tab-delimited file.
Specify a list of comma separated numbers to join datasets based on several columns at the same time.
Identifiers i.e common field(s) must by exactly identical (case sensitive).
Unmatched lines will be output. Empty fields are left blank.

## Example

### Dataset1:

chr1 10 20 geneA
chr1 50 80 geneB
chr5 10 40 geneL

### Dataset2:

geneA tumor-supressor
geneB Foxp2
geneC Gnas1
geneE INK4a

Joining the 4th column of Dataset1 with the 1st column of Dataset2 will yield:

geneA chr1    10      20      tumor-supressor
geneB chr1    50      80      Foxp2
geneL chr5    10      40
geneC                         Gnas1
geneE                         INK4a


## Codes to identify RESS-LADs (He et al.)

### The following software/packages are required:
1. [R](https://www.r-project.org/ "R")
2. [bedtools](https://github.com/arq5x/bedtools2 "bedtools")

### Prepare input files and metadata
Firstly, align the CUT&Tag data and generate the BED format files, then call peaks using
[MACS2](https://github.com/macs3-project/MACS "MACS") to generate narrowPeaks.

Then, prepare the metadata for LaminAC and LaminB1 experients seperately. The metadata
should contain 5 columns seperated by TAB:
```
Column 1: sample ID
Column 2: category. Must be CTR or APH
Column 3: path to the peak file
Column 4: path to the alignment BED file. Could be gzipped, but must be sorted (-k1,1 -k2,2n)
Column 5: number of clean reads
```
We had prepared `LaminAC.info` and `LaminB1.info` in this package as examples, but the users
may need to amend them by updating the file paths.

### Run the scripts
The main script is `screen.RESS-LADs.sh`, which takes the metadata files as inputs.
Here is the command and output information when running it:
```
user@linux$ sh screen.RESS-LADs.sh LaminAC.info LaminB1.info
Processing peak regions ...
Counting reads ...
Screening RESS-LADs ...
Cleaning up ...
Done.
```

## Output explaination
The following files will be generated after running the scripts, which are also included in this package:
```
Lamin.RPM.gz : normalized read counts and statistical test results for stitched peaks (gzipped file)
RESS-LADs.bed: final RESS-LADs list in BED format
```


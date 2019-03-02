a shell script automazing the flow of hisat2-build, hisat2-align-s, picard & cufflinks

## Usage
1. unify the files as follow:
```
current_dir
  |-- data
        |-- genome.fna.gz    # the genome file
        |-- samples       # all the RNA samples, sperated into directories
              |-- one_of_your_sample
                    |-- R1.fastq.gz
                    |-- R2.fastq.gz
  |-- results     # separated by your sample
```

2. give the script execution permission:
```
chmod u+x auto-hisat2.sh
```

3. set the right param and run. for example:
```
HISAT2_DIR=/path/to/hisat2-2.1.0 \
PICARD_JAR=/path/to/picard.jar \
CUFFLINKS=/path/to/cufflinks \
GENOME=genome_name \
THREADS=max_threads \
./auto-hisat2.sh
```

4. check output in results' `log`s or error in `.err`s

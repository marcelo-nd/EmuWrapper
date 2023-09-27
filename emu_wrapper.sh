#!/bin/bash

while getopts ":d:s:o:b:n:" option; do
  case $option in
    h)
      echo "Usage: $0 [-d Database EMU_DATABASE_DIR] [-s sequences_path] [-o output_path] [-b barcodes_to_merge] [n sample_names]"
      exit 1
      ;;
    d)
      # Set the database directory
      export EMU_DATABASE_DIR="$OPTARG"
      ;;
    s)
      # Set the sequences directory
      sequences_path="$OPTARG"
      ;;
    o)
      # Set Output directory path
      output_path="$OPTARG"
      ;;
    b)
      # Set barcodes to merge
      barcodes_to_merge="$OPTARG"
      ;;
    n)
      # Set sample names
      sample_names="$OPTARG"
      ;;
  esac
done
# Print parsed Database directory path
echo "Database path: $EMU_DATABASE_DIR"
# Print parsed Sequences directory path
echo "Sequences path: $sequences_path"
# Print parsed Output directory path
echo "Output path: $output_path"
# Print barcodes to merge
echo "Barcode tables to be merged: $barcodes_to_merge"
# Print sample names
echo "Sample names: $sample_names"

# Prefix for the names of barcode folders. Maybe it changes in the future or can ask user.
export prefix="barcode";
#echo "prefix: $prefix"
# Get the directories for all the barcodes
barcode_dir_list=`ls -d $sequences_path/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"
# PART 1 UNZIP GZ FILES:
# For loop to Unzip fastaq files
# Iterate over the list of barcode directories.
for bc_dir in $barcode_dir_list;
# If barcode directory contains files
# First get the list of files
do files=$(shopt -s nullglob dotglob; echo $bc_dir/*);
# if list of files variable contains something
if (( ${#files} ));
# If barcode/fastaq directory does not exists
if ! [ -d "$bc_dir/fastq/" ];
# create "fastaq" directory
then mkdir $bc_dir/fastq
fi
then echo "Unzipping files in: $bc_dir";
#echo $files
for f in $bc_dir/*.gz; do
# Run gunzip, retain files and extract in "fastaq" directory
  STEM=$(basename "${f}" .gz)
  # gunzip: c flag is for keeping original files, f flag is to replace the ones that exist in output if they have the same name
  gunzip -c -f "${f}" > $bc_dir/fastq/"${STEM}"
done
# Concat fastq files to run EMU once per barcode
#echo {$bc_dir}
a="$bc_dir"
echo ${a: -9:9}
cat $bc_dir/fastq/* > $bc_dir/fastq/"${a: -9:9}_concat.fastq"
fi
done
# PART 2 RUN EMU
# Iterate over the list of barcode directories to run emu.
for bc_dir in $barcode_dir_list;
do echo $bc_dir;
# If barcode/fastaq directory exists
if [ -d "$bc_dir/fastq/" ];
# RUN emu!!!
then fq_file=$bc_dir/fastq/*_concat.fastq;
echo $fq_file;
emu abundance $fq_file --output-dir $output_path --keep-counts;
# If the fastq folder does not exist tell the user.
else echo "fastq folder doesn't exist";
fi
done
# PART 3 MERGE THE TABLES INTO ONE OTU TABLE THAT CONTAINS ALL BARCODES SELECTED BY USER
#Execute R to merge the tables
Rscript ./tables_merging.R "/mnt/c/Users/Marcelo/Desktop/results/" $barcodes_to_merge $sample_names

#!/bin/bash
# Print parsed Database directory path
echo "Database path: $1"
# Print parsed Sequences directory path
echo "Sequences path: $2"
# Print parsed Output directory path
echo "Output path: $3"
# Set the database directory
export EMU_DATABASE_DIR=$1
# echo "Output path: $EMU_DATABASE_DIR"
# Prefix for the names of barcode folders. Maybe it changes in the future.
export prefix="barcode";
#echo "prefix: $prefix"
# Get the directories for all the barcodes
barcode_dir_list=`ls -d $2/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"
# For loop to Unzip fastaq files
# Iterate over the list of barcode directories.
for bc_dir in $barcode_dir_list;
# If barcode directory contains files
# First get the list of files
do files=$(shopt -s nullglob dotglob; echo $bc_dir/*);
# if "files" variable contains something
if (( ${#files} ));
# create "fastaq" directory
mkdir $bc_dir/fastq
then echo "Unzipping files in: $bc_dir";
#echo $files
for f in $bc_dir/*.gz; do
# Run gunzip, retain files and extract in "fastaq" directory
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > $bc_dir/fastq/"${STEM}"
done
# Concat fastq files
#echo {$bc_dir}
a="$bc_dir"
echo ${a: -9:9}
cat $bc_dir/fastq/* > $bc_dir/fastq/"${a: -9:9}_concat.fastq"
fi
done
# Iterate over the list of barcode directories to run emu.
for bc_dir in $barcode_dir_list;
do echo $bc_dir;
# If barcode/fastaq directory exists
if [ -d "$bc_dir/fastq/" ];
# get the list of fastq files
#then export barcode_files=$bc_dir/fastaq/*;
#echo $barcode_files;
#for fq_file in $barcode_files;
#do echo $fq_file;
# RUN emu!!!
then fq_file=$bc_dir/fastq/*_concat.fastq;
echo $fq_file;
emu abundance $fq_file --output-dir $3 --keep-counts;
#done;
# If the fastq folder doesnot exist tell the user.
else echo "fastq folder does not exist";
fi
done
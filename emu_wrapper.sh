#!/bin/bash
echo "Database path: $1"
# ./emu_std_database
# ./LaCa
echo "Sequences path: $2"
# /mnt/c/Users/Marcelo/Desktop/230815_Marcelo/230816-Marcelo/230816-Marcelo/20230816_1015_MN31656_FAR91361_edfa8c58/fastq_pass
echo "Output path: $3"
# /mnt/c/Users/Marcelo/Desktop/results
export EMU_DATABASE_DIR=$1
# echo "Output path: $EMU_DATABASE_DIR"
# Get the directories for all the barcodes
export prefix="barcode";
#echo "prefix: $prefix"
barcode_dir_list=`ls -d $2/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"
# Unzip fastaq files
# Iterate over the list of barcode directories.
for bc_dir in $barcode_dir_list;
# If barcode directory contains files
do files=$(shopt -s nullglob dotglob; echo $bc_dir/*);
if (( ${#files} ));
mkdir $bc_dir/fastaq
then echo "Unzipping files in: $bc_dir";
#echo $files
for f in $bc_dir/*.gz; do
  STEM=$(basename "${f}" .gz)
  gunzip -c "${f}" > $bc_dir/fastaq/"${STEM}"
done
fi
done
# Iterate over the list of barcode directories to run emu.
for bc_dir in $barcode_dir_list;
do echo $bc_dir;
# If barcode/fastaq directory exists
if [ -d "$bc_dir/fastaq/" ];
then export barcode_files=$bc_dir/fastaq/*;
#echo $barcode_files;
for fq_file in $barcode_files;
do echo $fq_file;
emu abundance $fq_file --output-dir $3 --keep-counts;
done;
else echo "fastaq folder does not exist"
fi
done
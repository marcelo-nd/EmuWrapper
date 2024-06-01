#!/bin/bash

EMU_DATABASE_DIR=''
sequences_path=''
output_path=''

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
BLUE='\033[34m'

function print_usage {
    echo "usage: [-d database] [-s sequences] [-o output] [-b barcodes] [-n names]"
    echo "  -h      print help"
    echo "  -d      specify Emu database path to be used"
    echo "  -s      specifiy the path to your sequence zip files"
    echo "  -z      specify if you want to unzip barcode sequences ("TRUE" or "FALSE")"
    echo "  -o      specifiy the output path were OTU tables are going to be stored"
    echo "  -c      specify if you want to perferom copy number adjustment ("TRUE" or "FALSE")"
    echo "  -p      specify the path to the copy number database"
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
	print_usage
  return
fi

# Reset OPTIND to wnter while loop assignment
OPTIND=1

while getopts 'd:s:z:o:c:p:n:' flag; do
#echo "assigning variables"
  case "${flag}" in
    d)
      # Set the database directory
      export EMU_DATABASE_DIR="${OPTARG}" ;;
    s)
      # Set the sequences directory
      sequences_path="${OPTARG}" ;;
    o)
      # Set Output directory path
      output_path="${OPTARG}" ;;
    c)
      # set if copy number adjustment is going to be performed
      copy_adjust="${OPTARG}" ;;
    p)
      # set copy database path
      copy_db_path="${OPTARG}" ;;
    *)
      print_usage
      return
  esac
done

# Print parsed Database directory path
echo -e "${BLUE}Database path: $EMU_DATABASE_DIR${NC}"
# Print parsed Sequences directory path
echo -e "${BLUE}Sequences path: $sequences_path${NC}"
# Print parsed Output directory path
echo -e "${BLUE}Output path: $output_path${NC}"

# Prefix for the names of barcode folders. Maybe it changes in the future or can ask user.
export prefix="barcode";
#echo "prefix: $prefix"
# Get the directories for all the barcodes
barcode_dir_list=`ls -d $sequences_path/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"

if ! [ -d "$output_path/emu_results/" ];
      # create "fastaq" directory
      then mkdir $output_path/emu_results
    fi

# PART 2 RUN EMU
# Iterate over the list of barcode directories to run emu.
for bc_dir in $barcode_dir_list;
  do
  # echo $bc_dir;
  # If barcode/fastaq directory exists, it will, delete
    if [ "TRUE" == "TRUE" ];
    # RUN emu!!!
      then fq_file=$bc_dir/*_qc.fastq;
      #echo $fq_file;
      echo -e "${GREEN}Running emu on : $fq_file${NC}"
      emu abundance $fq_file --output-dir $output_path/emu_results --keep-counts --keep-files --keep-read-assignments --N 50 --threads 6;
    # If the fastq folder does not exist tell the user.
    else echo "${RED}fastq folder doesn't exist${NC}";
    fi
done

# PART 3 MERGE THE TABLES INTO ONE OTU TABLE THAT CONTAINS ALL BARCODES SELECTED BY USER
#Execute R to merge the tables
Rscript $EMUWRAPPER_LOC/tables_merging.R $output_path/emu_results $copy_adjust $copy_db_path

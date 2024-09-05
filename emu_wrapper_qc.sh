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
    echo "  -s      specifiy the path to your sequence zip files"
    echo "  -o      specifiy the output path were OTU tables are going to be stored"
    echo "  -q      specify if you want to perferom copy number adjustment ("TRUE" or "FALSE")"
    echo "  -min      specify if you want to perferom copy number adjustment ("TRUE" or "FALSE")"
    echo "  -max      specify if you want to perferom copy number adjustment ("TRUE" or "FALSE")"
}

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
	print_usage
  return
fi

# Reset OPTIND to wnter while loop assignment
OPTIND=1

while getopts 's:o:q:l:h:' flag; do
#echo "assigning variables"
  case "${flag}" in
    s)
      # Set the sequences directory
      sequences_path="${OPTARG}" ;;
    o)
      # Set Output directory path
      output_path="${OPTARG}" ;;
    q)
      # Set Output directory path
      quality_score="${OPTARG}" ;;
    l)
      # Set Output directory path
      min_length="${OPTARG}" ;;
    h)
      # Set Output directory path
      max_length="${OPTARG}" ;;
    *)
      print_usage
      return
  esac
done

# Print parsed Sequences directory path
echo -e "${BLUE}Sequences path: $sequences_path${NC}"
# Print parsed Output directory path
#echo -e "${BLUE}Output path: $output_path${NC}"
# Print quality score, min and max lengths.
echo -e "${BLUE}Quality score: $quality_score${NC}"
echo -e "${BLUE}Min. length: $min_length${NC}"
echo -e "${BLUE}Max. length: $max_length${NC}"

# Prefix for the names of barcode folders. Maybe it changes in the future or can ask user.
export prefix="barcode";
#echo "prefix: $prefix"
# Get the directories for all the barcodes
barcode_dir_list=`ls -d $sequences_path/$prefix*`
#echo "Barcode directories list: $barcode_dir_list"

# Create output fastaq directory
    if ! [ -d "$output_path/fastq_qc/" ];
      # create "fastaqc" directory
      then mkdir $output_path/fastq_qc
    fi
# PART 1. Run chopper on every fastq file for every barcode* subfolder in "sequences_path"
# Iterate over the list of barcode directories to run emu.
for bc_dir in $barcode_dir_list;
  do
  # echo $bc_dir;
  a="$bc_dir"
  # If barcode/fastaq directory exists, it will, delete
    if [ "TRUE" == "TRUE" ];
    # Create barcode subfolder in fastq_qc
      then fq_file=$bc_dir/*_concat.fastq;
      mkdir $output_path/fastq_qc/${a: -9:9}
      #echo $fq_file;
      echo -e "${GREEN}Running chopper on : $fq_file${NC}"
      chopper --quality $quality_score --minlength $min_length --maxlength $max_length -i $fq_file > $output_path/fastq_qc/${a: -9:9}/"${a: -9:9}_qc.fastq";
    # If the fastq folder does not exist tell the user.
    else echo "${RED}fastq folder doesn't exist${NC}";
    fi
done

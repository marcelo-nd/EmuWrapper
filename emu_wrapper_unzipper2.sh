#!/bin/bash

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

while getopts 's:o:' flag; do
#echo "assigning variables"
  case "${flag}" in
    s)
      # Set the sequences directory
      sequences_path="${OPTARG}" ;;
    o)
      # Set Output directory path
      output_path="${OPTARG}" ;;
    *)
      print_usage
      return
  esac
done

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
# PART 1 UNZIP GZ FILES:
# For loop to Unzip fastaq files
# Iterate over the list of barcode directories if user already has unzip packages
if [ "TRUE" == "TRUE" ];
then
for bc_dir in $barcode_dir_list;
# If barcode directory contains files
# First get the list of files
  do files=$(shopt -s nullglob dotglob; echo $bc_dir/*);
    #echo {$bc_dir}
    a="$bc_dir"
    #echo ${a: -9:9}
    # if list of files variable contains something
    if (( ${#files} ));
      # If barcode/fastaq directory does not exists
      if ! [ -d "$bc_dir/fastq/" ];
      # create "fastaq" directory
      then mkdir $bc_dir/fastq
      fi
    then echo -e "${GREEN}Unzipping files in: $bc_dir${NC}";
    #echo $files
      for f in $bc_dir/*.gz; do
      # Run gunzip, retain files and extract in "fastaq" directory
      STEM=$(basename "${f}" .gz)
      # gunzip: c flag is for keeping original files, f flag is to replace the ones that exist in output if they have the same name
      gunzip -c -f "${f}" > $bc_dir/fastq/"${STEM}"
      done
    # Concat fastq files to run EMU once per barcode  
    cat $bc_dir/fastq/* > $bc_dir/fastq/"${a: -9:9}_concat.fastq"
    fi
done
fi

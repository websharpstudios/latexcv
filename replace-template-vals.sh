#!/bin/bash

# Step 1: Delete all PDF files in the current directory
find . -type f -name '*.pdf' -exec rm {} +

# Step 2: Read the .map file and store the mappings
declare -A map
while IFS='=' read -r key value; do
    map["$key"]="$value"
done < "file.map"

# Step 3: Replace template values in .replace text files
for replace_file in *.replace; do
    for key in "${!map[@]}"; do
        sed -i "s/$key/${map[$key]}/g" "$replace_file"
    done
done

# Step 4: Search for \usepackage in .tex files and unzip package.zip if found
for tex_file in *.tex; do
    if grep -q '\\usepackage' "$tex_file"; then
        # Assuming the script is run from the directory containing the .tex files
        unzip ../package.zip -d .
    fi
done

# Give execution permission to the script


#!/bin/bash

# Define the directory containing .tex files
TEX_DIR=~/latexcv

# Define the base URL for downloading packages
CTAN_BASE_URL="https://mirrors.ctan.org/macros/latex/contrib"

# Create a temporary file to store package names
PACKAGES_LIST=$(mktemp)

# Find all .tex files and extract package names
find "$TEX_DIR" -name "*.tex" -exec grep -oP '\\usepackage(\[.*?\])?\{.*?\}' {} \; | \
    sed -E 's/\\usepackage(\[.*?\])?\{(.*)\}/\2/g' | \
    sort | uniq > "$PACKAGES_LIST"

# Read the package list and download/unzip each package
while read -r package; do
    # Skip empty lines
    if [[ -z "$package" ]]; then
        continue
    fi

    # Define the package URL and the output zip file path
    package_url="$CTAN_BASE_URL/$package.zip"
    output_zip="$TEX_DIR/$package.zip"

    # Download the package zip file
    echo "Downloading $package..."
    curl -f -o "$output_zip" "$package_url" --silent

    # Check if the download was successful and the file is a ZIP archive
    if [[ $? -eq 0 ]] && file "$output_zip" | grep -q "Zip archive data"; then
        # Unzip the package into the TEX_DIR
        echo "Unzipping $package..."
        unzip -o "$output_zip" -d "$TEX_DIR"
        # Remove the zip file after extraction
        #rm "$output_zip"
    fi
done < "$PACKAGES_LIST"

# Remove the temporary file
rm "$PACKAGES_LIST"

echo "All packages processed."

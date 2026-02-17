#!/bin/bash

# Script to merge all files from matching nested folders in two source folders into a destination folder

SOURCE_FOLDER1="$1"
SOURCE_FOLDER2="$2"
DEST_FOLDER="$3"

# Validate inputs
if [[ -z "$SOURCE_FOLDER1" || -z "$SOURCE_FOLDER2" || -z "$DEST_FOLDER" ]]; then
    echo "Usage: $0 <source_folder1> <source_folder2> <destination_folder>"
    exit 1
fi

# Create destination folder if it doesn't exist
mkdir -p "$DEST_FOLDER"

# Find all directories in SOURCE_FOLDER1
while IFS= read -r dir1; do
    # Get the relative path from SOURCE_FOLDER1
    relpath="${dir1#$SOURCE_FOLDER1/}"
    dir2="$SOURCE_FOLDER2/$relpath"
    dest_dir="$DEST_FOLDER/$relpath"
    
    # Create destination subdirectory
    mkdir -p "$dest_dir"
    
    # Copy all files from folder1
    if [[ -d "$dir1" ]]; then
        for file in "$dir1"/*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                cp "$file" "$dest_dir/$filename"
                echo "Copied from folder1: $relpath/$filename"
            fi
        done
    fi
    
    # Copy/merge all files from folder2 (with suffix if name conflicts)
    if [[ -d "$dir2" ]]; then
        for file in "$dir2"/*; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                dest_file="$dest_dir/$filename"
                
                # If file already exists from folder1, append to it
                if [[ -f "$dest_file" ]]; then
                    cat "$file" >> "$dest_file"
                    echo "Appended from folder2: $relpath/$filename"
                else
                    cp "$file" "$dest_file"
                    echo "Copied from folder2: $relpath/$filename"
                fi
            fi
        done
    fi
done < <(find "$SOURCE_FOLDER1" -type d)

echo "Merge complete!"
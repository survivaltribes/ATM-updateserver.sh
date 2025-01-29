#!/bin/bash

### This Script attempts to update ATM8.

# Check for the correct number of arguments
if [ "$#" -ne 2 ]; then
	    echo "Usage: $0 <destination_folder> <zip_file>"
	        exit 1
	fi
destination_folder="$1"
zip_file="$2"

# Check if the destination folder exists
if [ ! -d "$destination_folder" ]; then
	    echo "Destination folder not found!"
	        exit 1
	fi

# Check if the zip file exists
if [ ! -f "$zip_file" ]; then
	    echo "Zip file not found!"
	        exit 1
	fi



# Check if there is a Java Process with forge running.  
# If so, get its Process ID and send a hangup signal to it.

PROCESSID=`ps a | grep "java[\ A-Za-z0-9-]*forge\.jar" | cut -b 1-5`
if [ -n "${PROCESSID}" ]
then
	  echo "Sending Minecraft Server a HUP"
	    kill -HUP ${PROCESSID}
fi


# Create a backup copy of the destination folder
backup_folder="$(echo "$destination_folder" | tr -d '/')bkp_$(date +'%Y_%m_%d_%H-%M-%S')"
cp -rv "$destination_folder" "$backup_folder"
echo "Backup copy of $destination_folder created: $backup_folder"


#Archive and compress the backup folder using tar
tar_file="$backup_folder.tar.gz"
tar -cvzf "$tar_file" "$backup_folder"
echo "Backup folder archived and compressed: $tar_file"
rm -r "$backup_folder"


# Remove the libraries folder in the destination folder
if [ -d "$destination_folder/libraries" ]; then
	    echo "Removing libraries folder from destination..."
	        rm -r "$destination_folder/libraries"
		    echo "Libraries folder removed."
fi

# Remove unwanted files from the destination folder
# This prevents old or conflicting startup scripts and mod loader files from causing issues.
echo "Removing unnecessary files from destination..."
rm -vf "$destination_folder/startserver.sh" "$destination_folder/neoforge"* || true
echo "Unnecessary files removed."

# Unzip the specified zip_file
unzipped_folder=$(basename "$zip_file" .zip)
unzip "$zip_file"
echo "Zip file extracted to: $unzipped_folder"


# Remove uneeded  file from the unzipped folder
rm -v "$unzipped_folder/server-icon.png" "$unzipped_folder/startserver.bat" "$unzipped_folder/user_jvm_args.txt"
echo "Removed the uneeded file $unzipped_folder"


# Remove corresponding files in the destination folder
unzipped_files=$(find "$unzipped_folder" -type f -printf "%f\n")
for file in $unzipped_files; do
	    if [ -e "$destination_folder/$file" ]; then
		    rm -vf "$destination_folder/$file"
	    fi
done



# Remove folders in the destination folder that are also present in the unzipped folder
for folder in "$destination_folder"/*; do
	    folder_name=$(basename "$folder")
	        if [ -d "$unzipped_folder/$folder_name" ]; then
			        rm -rv "$folder"
		fi
done


# Move unzipped files into the destination folder
mv "$unzipped_folder"/* "$destination_folder"
echo "Unzipped files moved to $destination_folder"


#!/bin/bash

# @package 		    Another Simple Renamer
# 
# @author			Brett Shenk
# @version			0.7.0
# @license			Creative Commons Attribution 4.0  https://choosealicense.com/licenses/cc-by-4.0/
# @copyright		2024
#
# @var [bool] 			rename_status	Should the files be renamed? [true, false]
# @var [array|string] 	path			Folder Paths to be searched.
#
# Should we echo or rename the file being processed?
status=true			# Temporary

# Should we rename the file being processed?
rename_status=true

# Full file path to process
declare -a path=(
	'/your-path-here/'
)

echo 

# Loop over all paths in the array one at a time and change to it's directory
for single_folder in "${path[@]}"
do
   	cd "$single_folder"

	# Folder contain the following characters in the name?  [*]
	# If missing, it's assumed to already be done.
	find ./ -maxdepth 1 -iname "*\[*\]*" -type d -print0 | 
	while read -d $'\0' main_folder; do

		folder_char="./"		# Character removal
		result="${main_folder//$folder_char}"

		folder_char1="\[*\] "	# Character removal
		result="${result//$folder_char1}"

		folder_char2=" \[*\]"	# Character removal
		result="${result//$folder_char2}"

		cd "$main_folder"		# Change to show folder

		# Stuff for later
		new_show_name="$result"
		episode_numb=0
		season_numb=0

		leading_zero_fill (){
			printf "%0$1d\\n" "$2"
		}

		# Any video files in the main folder of the show?
		# Does not have season folders.
		find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
		sort -z | 
		while read -r -d '' line; do
			# s01e02.ext				show name - S01E01.ext
			# anything_s1e2.ext			show name S01E01.ext
			# anything_s01e02.ext
			match_show1="([S|s][0-9]{1,}[E|e][0-9]{1,})"

			# anything s1.e2.ext		anything_s01.e02.ext
			# anything_s01_e02.ext		anything s01 e02.ext
			# anything S01 E02.ext
			match_show2="([S|s][0-9]{1,}[-|_|\.|\s][E|e][0-9]{1,})"

			# Is the current file a movie or a tv show?
			if [[ $line =~ $match_show1 || $line =~ $match_show2 ]]; then
				is_tv_show=true
			else
				is_tv_show=false
			fi

			# Video file count without trailers and such
			video_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*[^-behindthescenes|^-deleted|^-featurette|^-interview|^-scene|^-short|^-other|^(^-|.|_)trailer|^(^-|.|_)sample|^-clip|^-deletedscene|^-extra].(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

			# Catch for some vague valid syntax that's otherwise problematic to search for
			if [[ $is_tv_show == false ]]; then
				if [[ "$video_count" -gt "3" ]]; then
					is_tv_show=true
				fi
			fi

			# Assume show specials are named properly already
			if [[ "$line" == *"-behindthescenes"* || "$line" == *"-deleted"* || "$line" == *"-featurette"* || "$line" == *"-interview"* || "$line" == *"-scene"* || "$line" == *"-short"* || "$line" == *"-other"* || "$line" == *"-trailer"* || "$line" == *".trailer"* || "$line" == *"_trailer"* || "$line" == *"-sample"* || "$line" == *".sample"* || "$line" == *"_sample"* || "$line" == *"-clip"* || "$line" == *"-deletedscene"* || "$line" == *"-extra"* ]]; then
				continue
			fi

			folder_char="./"	# Character removal
			line="${line//$folder_char}"

			# Is this a TV Show?
			if $is_tv_show; then
				((episode_numb++))

				# Episode Count Leading Zero
				if [[ "$video_count" -le "9999" ]]; then
					episode_count=$(leading_zero_fill 4 "$episode_numb")
				fi
				if [[ "$video_count" -le "999" ]]; then
					episode_count=$(leading_zero_fill 3 "$episode_numb")
				fi
				if [[ "$video_count" -le "99" ]]; then
					episode_count=$(leading_zero_fill 2 "$episode_numb")
				fi

				file_ending=${line#*.}
				new_name="$new_show_name"' - S01E'"$episode_count"."$file_ending";
			else
				file_ending=${line#*.}
				new_name="$new_show_name"."$file_ending";
			fi

			# Rename show file or echo 
			if $status; then
				if $rename_status; then
					mv "$line" "$new_name"
				else
					echo "$line"
					echo "$new_name"
				fi
			fi
		done # end show search


		# Does the folder contain sub folders labeled like:  Season
		find ./ -maxdepth 1 -type d -iname *'season'* -print0 | 
		sort -z | 
		while read -r -d '' season_folder; do
			folder_char="./"		# Character removal
			clean_folder="${season_folder//$folder_char}"

			# Season 0 and special folders are skipped
			if [[ $clean_folder == *'eason 0' || $clean_folder == *'eason 00' || $clean_folder == *'eason 000' || $clean_folder == *'eason 0000' ]]; then
				continue
			fi

			((season_numb++))

			cd "$season_folder"

			# Any video files in the main folder of the show?
			find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
			sort -z | 
			while read -r -d '' line; do

				# Video file count without trailers and such
				video_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*[^-behindthescenes|^-deleted|^-featurette|^-interview|^-scene|^-short|^-other|^(^-|.|_)trailer|^(^-|.|_)sample|^-clip|^-deletedscene|^-extra].(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

				# Assume show specials are named properly already
				if [[ "$line" == *"-behindthescenes"* || "$line" == *"-deleted"* || "$line" == *"-featurette"* || "$line" == *"-interview"* || "$line" == *"-scene"* || "$line" == *"-short"* || "$line" == *"-other"* || "$line" == *"-trailer"* || "$line" == *".trailer"* || "$line" == *"_trailer"* || "$line" == *"-sample"* || "$line" == *".sample"* || "$line" == *"_sample"* || "$line" == *"-clip"* || "$line" == *"-deletedscene"* || "$line" == *"-extra"* ]]; then
					continue
				fi

				folder_char="./"	# Character removal
				line="${line//$folder_char}"

				((episode_numb++))

				# Episode Count Leading Zero
				if [[ "$video_count" -le "9999" ]]; then
					episode_count=$(leading_zero_fill 4 "$episode_numb")
				fi
				if [[ "$video_count" -le "999" ]]; then
					episode_count=$(leading_zero_fill 3 "$episode_numb")
				fi
				if [[ "$video_count" -le "99" ]]; then
					episode_count=$(leading_zero_fill 2 "$episode_numb")
				fi

				season_count=$(leading_zero_fill 2 "$season_numb")
				file_ending=${line#*.}

				new_name="$new_show_name"' - S'"$season_count"E"$episode_count"."$file_ending";

				# Rename show file or echo 
				if $status; then
					if $rename_status; then
						mv "$line" "$new_name"
					else
						echo "$line"
						echo "$new_name"
					fi
				fi

			done # end show search

			# Change back to the shows main folder
			cd ../

		done #end season search

		# Change back to root directory of the array
		cd ../
		
		# Rename show folder
		if $rename_status; then
			mv "$main_folder" "$new_show_name"
		fi
	done
done

echo Done!

sleep 2
exit 1

#!/bin/bash

# @package 		    Another Simple Renamer
# 
# @author			Brett Shenk
# @version			0.8.0
# @license			Creative Commons Attribution 4.0  https://choosealicense.com/licenses/cc-by-4.0/
# @copyright		2024
#
# @var [bool] 			rename_status	Rename video files or run a test run and log all effected files. [true, false]
# @var [bool]			reset_perms		Reset permissions for the files in the folder paths. [true, false]
# @var [array|string] 	path			The folder paths to be searched.
# @var [string]			main_match		Logic for what folders will be included in the renaming process.

# Rename the file being processed? False for a test run.
rename_status=false

# Reset file permissions? False to skip the option.
reset_perms=false

# Full file path to process.
declare -a path=(
	'/home/serverm/Downloads/00 Scripts/'
)

# Default folder regex:  *[*]*
main_match="((.{1,})?\[.{1,}\](.{1,})?)"

echo 

# Loop over all paths in the array one at a time and change to it's directory.
for single_folder in "${path[@]}"
do
   	cd "$single_folder"

	# Reset video permissions.
	if $reset_perms; then
		echo "$single_folder"
		chmod 0777 -R ./*
		sudo chown nobody:users /*
	fi

	# Folders matching the variable:  $main_match
	# By default, if missing, it's assumed to already be done.
	find ./ -maxdepth 1 -type d -regextype posix-extended -regex "$main_match" -print0 | 
	while read -d $'\0' main_folder; do

		folder_char="./"		# Character removal
		result="${main_folder//$folder_char}"

		folder_char1="\[*\] "	# Character removal
		result="${result//$folder_char1}"

		folder_char2=" \[*\]"	# Character removal
		result="${result//$folder_char2}"

		cd "$main_folder"

		# Stuff for later
		new_show_name="$result"
		episode_numb=0
		season_numb=0
		check_movie_miniseries="NULL"
		check_season="NULL"

		leading_zero_fill (){
			printf "%0$1d\\n" "$2"
		}

		# Get all video files in the main folder. Not seasons.
		find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
		sort -z | 
		while read -r -d '' line; do
			# s01e02.ext				show name - S01E01.ext
			# anything_s1e2.ext			show name S01E01.ext		anything_s01e02.ext
			match_show1="([S|s][0-9]{1,}[E|e][0-9]{1,})"

			# anything s1.e2.ext		anything_s01.e02.ext
			# anything_s01_e02.ext		anything s01 e02.ext		anything S01 E02.ext
			match_show2="([S|s][0-9]{1,}[-|_|\.|\s][E|e][0-9]{1,})"

			# Is the current file a movie or a tv show?
			if [[ "$line" =~ "$match_show1" || "$line" =~ "$match_show2" ]]; then
				is_tv_show=true
			else
				is_tv_show=false
			fi

			# All video file count.
			video_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*.(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

			# Only video trailers and such.
			video_extra_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*(-behindthescenes|-deleted|-featurette|-interview|-scene|-short|-other|(-|.|_)trailer|(-|.|_)sample|-clip|-deletedscene|-extra).(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

			video_count=$(expr $video_count - $video_extra_count)

			# Catch for some vague valid syntax that's otherwise problematic to match.
			if [[ $is_tv_show == false ]]; then
				if [[ "$video_count" -gt "3" ]]; then
					is_tv_show=true
				fi
			fi

			# Assume show specials are named properly already.
			if [[ "$line" == *"-behindthescenes"* || "$line" == *"-deleted"* || "$line" == *"-featurette"* || "$line" == *"-interview"* || "$line" == *"-scene"* || "$line" == *"-short"* || "$line" == *"-other"* || "$line" == *"-trailer"* || "$line" == *".trailer"* || "$line" == *"_trailer"* || "$line" == *"-sample"* || "$line" == *".sample"* || "$line" == *"_sample"* || "$line" == *"-clip"* || "$line" == *"-deletedscene"* || "$line" == *"-extra"* ]]; then
				continue
			fi

			folder_char="./"	# Character removal
			line="${line//$folder_char}"

			# Is this a tv show?
			if $is_tv_show; then
				((episode_numb++))

				# Episode count leading zero fill.
				if [[ "$video_count" -le "9999" ]]; then
					episode_count=$(leading_zero_fill 4 "$episode_numb")
				fi
				if [[ "$video_count" -le "999" ]]; then
					episode_count=$(leading_zero_fill 3 "$episode_numb")
				fi
				if [[ "$video_count" -le "99" ]]; then
					episode_count=$(leading_zero_fill 2 "$episode_numb")
				fi

				file_ending=${line##*.}
				new_name="$new_show_name"' - S01E'"$episode_count"."$file_ending";
			else
				file_ending=${line##*.}
				new_name="$new_show_name"."$file_ending";
			fi

			# Does the current video need skipped?
			activity_test=$(fuser -f "$line" 2>&1);
			if [[ "$activity_test" ]]; then
				echo "Video is currently in use. Skipping: " "$line"
				check_movie_miniseries="false"
				continue
			fi
			if [[ $check_movie_miniseries = "NULL" || $check_movie_miniseries = "true" ]]; then
				check_movie_miniseries="true"
			fi

			# Confirm it doesn't exist and rename or echo it.
			if [[ -f "$new_name" ]]; then
				echo "File already exists with the new name. Skipped: " "$line"
			else
				if $rename_status; then
					mv "$line" "$new_name"
				else
					echo "$line"
					echo "$new_name"
				fi
			fi

			# Rename main folder if..
			# - Episode count is the same as the total video count
			# - Video files are not currently in use
			# - New folder name doesn't already exist
			if [[ "$episode_numb" = "$video_count" && $check_movie_miniseries = "true" ]]; then
				if [[ -d "$new_show_name" ]]; then
					echo "Folder already exists with the new name. Skipped: " "$main_folder"
				else
					if $rename_status; then
						mv "$main_folder" "$new_show_name"
						cd "$new_show_name"
					else
						echo "$new_show_name"
					fi
				fi
			fi
		done # end show search


		# Does the folder contain sub folders labeled like:  Season
		find ./ -maxdepth 1 -type d -iname *'season'* -print0 | 
		sort -z | 
		while read -r -d '' season_folder; do
			folder_char="./"		# Character removal
			clean_folder="${season_folder//$folder_char}"

			# Season 0 and special folders are skipped.
			if [[ "$clean_folder" == *"eason 0" || "$clean_folder" == *"eason 00" || "$clean_folder" == *"eason 000" || "$clean_folder" == *"eason 0000" ]]; then
				continue
			fi

			# Get the current season folder number to use otherwise, start a new count.
			season_match='[S|s]eason.([1-9]{1}[0]{3}|[1-9]{1}[0]{1,2}[1-9]{1,2}|[0]{1}[1-9]{1}[0]{1}|[1-9]{1,2}[0]{1,2}|[1-9]{1,4}|[0]{1,2}[1-9]{1})';
			if [[ "$clean_folder" =~ $season_match ]]; then
				season_count=${clean_folder#* }
				season_count=$(echo ${season_count} | cut -d ' ' -f 1)
				
				if [[ "$season_count" -le "9999" ]]; then
					season_count_zero=$(leading_zero_fill 4 "$season_count")
				fi
				if [[ "$season_count" -le "999" ]]; then
					season_count_zero=$(leading_zero_fill 3 "$season_count")
				fi
				if [[ "$season_count" -le "99" ]]; then
					season_count_zero=$(leading_zero_fill 2 "$season_count")
				fi
			else
				season_count_zero=$(leading_zero_fill 2 "$season_numb")
			fi

			total_season_count=$(find ./ -type d -regextype posix-extended -regex './[S|s]eason.([1-9]{1}[0]{3}|[1-9]{1}[0]{1,2}[1-9]{1,2}|[0]{1}[1-9]{1}[0]{1}|[1-9]{1,2}[0]{1,2}|[1-9]{1,4}|[0]{1,2}[1-9]{1})([[:space:]]\([0-9]{2,}\-[0-9]{2,}\))?([[:space:]]\([0-9]{4,}\))?' -printf x | wc -c)

			((season_numb++))
			
			cd "$season_folder"

			# Get all video files in the season folder.
			find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
			sort -z | 
			while read -r -d '' line; do

				# All video file count.
				video_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*.(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

				# Only video trailers and such.
				video_extra_count=$(find ./ -maxdepth 1 -type f -regextype posix-extended -regex '.*(-behindthescenes|-deleted|-featurette|-interview|-scene|-short|-other|(-|.|_)trailer|(-|.|_)sample|-clip|-deletedscene|-extra).(mp4|mov|avi|wmv|flv|f4v|mkv|webm|m4v|3gp|3g2|ogv|vob|avchd|mpg|mpeg2|mxf)' -printf x | wc -c)

				video_count=$(expr $video_count - $video_extra_count)

				# Assume show specials are named properly already.
				if [[ "$line" == *"-behindthescenes"* || "$line" == *"-deleted"* || "$line" == *"-featurette"* || "$line" == *"-interview"* || "$line" == *"-scene"* || "$line" == *"-short"* || "$line" == *"-other"* || "$line" == *"-trailer"* || "$line" == *".trailer"* || "$line" == *"_trailer"* || "$line" == *"-sample"* || "$line" == *".sample"* || "$line" == *"_sample"* || "$line" == *"-clip"* || "$line" == *"-deletedscene"* || "$line" == *"-extra"* ]]; then
					continue
				fi

				folder_char="./"	# Character removal
				line="${line//$folder_char}"

				((episode_numb++))

				# Episode count leading zero fill.
				if [[ "$video_count" -le "9999" ]]; then
					episode_count=$(leading_zero_fill 4 "$episode_numb")
				fi
				if [[ "$video_count" -le "999" ]]; then
					episode_count=$(leading_zero_fill 3 "$episode_numb")
				fi
				if [[ "$video_count" -le "99" ]]; then
					episode_count=$(leading_zero_fill 2 "$episode_numb")
				fi

				file_ending=${line##*.}
				new_name="$new_show_name"' - S'"$season_count_zero"E"$episode_count"."$file_ending";

				# Skip the current video?
				activity_test=$(fuser -f "$line" 2>&1);
				if [[ "$activity_test" ]]; then
					echo "Video is currently in use. Skipping: " "$line"
					check_season=false
					continue
				fi
				if [[ $check_season = "NULL" || $check_season = true ]]; then
					check_season=true
				fi

				# Confirm it doesn't exist and rename or echo it.
				if [[ -f "$new_name" ]]; then
					echo "File already exists with the new name. Skipped: " "$line"
				else
					if $rename_status; then
						mv "$line" "$new_name"
					else
						echo "$line"
						echo "$new_name"
					fi
				fi

				# Rename main folder if..
				# - Episode count is the same as the total video count
				# - Video files are not currently in use
				# - Last season in the series?
				# - New folder name doesn't already exist
				if [[ "$episode_numb" = "$video_count" && $check_season = "true" && "$total_season_count" = "$season_numb" ]]; then
					if [[ -d "$new_show_name" ]]; then
						echo "Folder already exists with the new name. Skipped: " "$main_folder"
					else
						if $rename_status; then
							mv "$main_folder" "$new_show_name"
							cd "$new_show_name"
						else
							echo "$new_show_name"
						fi
					fi
				fi
			done # end show search

			# Change back to the shows main folder.
			cd ../

		done #end season search

		# Change back to root directory of the array.
		cd ../

		if ! $rename_status; then
			echo
		fi

	done
done

echo Done!

sleep 2
exit 1

#!/bin/bash

# @package 		    Another Simple Renamer
# 
# @author			Brett Shenk
# @version			0.10.0
# @license			Creative Commons Attribution 4.0  https://choosealicense.com/licenses/cc-by-4.0/
# @copyright		2024
#
# @var [bool] 			$rename_status	Rename video files or run a test run and log all effected files.
# @var [array] 			$path			The folder paths to be searched. Key is only required if mover is enabled.
# @var [bool]			$mover_status	Weather to move the video files after being renamed.
# @var [array]			$mover_path		Where to move the newly renamed video files. Required if mover_status is true.
# @var [string]			$main_match		Logic for what folders will be included in the renaming process.
# @var [bool]			$reset_perms	Reset permissions for the videos in the folder paths.
# @var [bool]			$reset_owner	Reset the owner for the videos in the folder paths.
#
################################################
# START EDITING
################################################

# Rename the file being processed? False for a test run.
rename_status=false

# Full file path to process.
declare -A path=(
	["dub"]="/home/darth-igras/Downloads/00_test/0-one/"
)

# Move the files after being processed? False to skip.
mover_status=false

# Mover Output Location(s)
declare -A mover_path=(
	["dub"]="/home/darth-igras/Downloads/00_test/1-two/"
)

# To include all folders: "(.{1,})"
# Default folder regex:   *[*]*
# main_match="((.{1,})?\[.{1,}\](.{1,})?)"
main_match="(.{1,})"

# Reset file permissions? False to skip.
reset_perms=false

# Reset file owner? False to skip.
reset_owner=false

################################################
# STOP EDITING
################################################

echo 

# Get the OS type
platform='unknown'
UNAME=$( command -v uname)
case $( "${UNAME}" | tr '[:upper:]' '[:lower:]') in
	linux*)
    	platform='linux'
    	;;
	darwin*)
    	platform='darwin'
    	;;
	freebsd*)
		platform='freebsd'
		;;
	msys*|cygwin*|mingw*|nt|win*)
		platform='windows'
		;;
	*)
    	platform='unknown'
    	;;
esac



leading_zero_fill (){
	printf "%0$1d\\n" "$2"
}

# Primary Function
another_simple_renamer () {
	# Localize global variables for compatibility
	local is_tv_show main_folder season_count_total new_show_name platform rename_status mover_status single_folder move_folder

	# Set function arguments
	is_tv_show="$1"
	main_folder="$2"
	season_count_total="$3"
	new_show_name="$4"
	episode_numb="$5"
	platform="$6"
	check_season="$7"
	rename_status="$8"
	mover_status="$9"
	single_folder="${10}"
	move_folder="${11}"
	total_season_count="${12}"
	season_numb="${13}"

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
	if [[ "$main_folder" == *"-behindthescenes"* || "$main_folder" == *"-deleted"* || "$main_folder" == *"-featurette"* || "$main_folder" == *"-interview"* || "$main_folder" == *"-scene"* || "$main_folder" == *"-short"* || "$main_folder" == *"-other"* || "$main_folder" == *"-trailer"* || "$main_folder" == *".trailer"* || "$main_folder" == *"_trailer"* || "$main_folder" == *"-sample"* || "$main_folder" == *".sample"* || "$main_folder" == *"_sample"* || "$main_folder" == *"-clip"* || "$main_folder" == *"-deletedscene"* || "$main_folder" == *"-extra"* ]]; then
		continue
	fi

	folder_char="./"	# Character removal
	main_folder="${main_folder//$folder_char}"

	((episode_numb++))

	# Is this a tv show?
	if $is_tv_show; then

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

		file_ending=${main_folder##*.}
		new_name="$new_show_name"' - S'"$season_count_total"E"$episode_count";
	else
		file_ending=${main_folder##*.}
		new_name="$new_show_name";
	fi

	# Skip the current video?
	# fuser  is not supported by all platforms. Skip function if needed until a replacement is found.
	if [[ "$platform" != 'windows' ]]; then
		activity_test=$(fuser -f "$main_folder" 2>&1);
		if [[ "$activity_test" ]]; then
			echo "Video is currently in use. Skipping: " "$main_folder"
			check_season=false
			continue
		fi
	fi
	if [[ $check_season = "NULL" || $check_season = true ]]; then
		check_season=true
	fi

	# Confirm it doesn't exist and rename or echo it.
	if [[ -f "$new_name"."$file_ending" ]]; then
		echo "File already exists with the new name. Skipped: " "$main_folder"
	else
		if $rename_status; then
			mv "$main_folder" "$new_name"."$file_ending"
			echo "Renaming ""$new_name"."$file_ending"
		else
			echo "$main_folder"
			echo "$new_name"."$file_ending"
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
			echo
		else
			if $rename_status; then
				show_name='./'"$new_show_name"
				if [[ "$main_folder" != "$show_name" ]]; then
					cd "$single_folder"
					mv "$main_folder" "$new_show_name"
				fi

				if $mover_status; then
					cd "$single_folder"
					mv "$new_show_name" "$move_folder"
				fi
			fi
		fi
	fi
}



# Loop over all paths in the array one at a time and change to it's directory.
for folder_key in ${!path[@]}
do
	single_folder="${path[${folder_key}]}"

	folder_char="/,"		# Character removal
	single_folder="${single_folder//$folder_char}"

   	cd "$single_folder"

	# Reset video permissions.
	if $reset_perms; then
		chmod 0777 -R ./*
	fi

	# Reset video owner.
	if $reset_owner; then
		sudo chown nobody:users /*
	fi



	# Folders matching the variable:  $main_match
	# By default, if missing, it's assumed to already be done.
	find ./ -maxdepth 1 -type d -regextype posix-extended -regex "$main_match" -print0 | 
	while read -d $'\0' main_folder; do

		# Skip main folder
		if [[ "$main_folder" = "./" ]]; then
			continue
		fi

		# Match mover_path with path if enabled.
		if $mover_status; then
			for mover_key in ${!mover_path[@]}
			do
				if [[ "${mover_key}" == "${folder_key}" ]]; then
					move_folder="${mover_path[${mover_key}]}"

					folder_char="/,"		# Character removal
					move_folder="${move_folder//$folder_char}"
				fi
			done
		else
			move_folder="null"
		fi

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
		check_season="NULL"



		# Get all video files in the main folder. Not seasons.
		find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
		sort -z | 
		while read -r -d '' main_folder; do
			# s01e02.ext				show name - S01E01.ext
			# anything_s1e2.ext			show name S01E01.ext		anything_s01e02.ext
			match_show1="([S|s][0-9]{1,}[E|e][0-9]{1,})"

			# anything s1.e2.ext		anything_s01.e02.ext
			# anything_s01_e02.ext		anything s01 e02.ext		anything S01 E02.ext
			match_show2="([S|s][0-9]{1,}[-|_|\.|\s][E|e][0-9]{1,})"

			# Is the current file a movie or a tv show?
			if [[ "$main_folder" =~ "$match_show1" || "$main_folder" =~ "$match_show2" ]]; then
				is_tv_show=true
			else
				is_tv_show=false
			fi

			another_simple_renamer "$is_tv_show" "$main_folder" 1 "$new_show_name" "$episode_numb" "$platform" "$check_season" "$rename_status" "$mover_status" "$single_folder" "$move_folder" 1 1

		done # end show search


		check_season="NULL"


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

			# Get the current season folder number to use otherwise, start a new count. Matches similar to:
			# Season 2000			Season 3241			Season 59 			season 003			Season 10
			# Season 3000			Season 8562			Season 22			season 006			Season 120
			# season 2021			season 1			season 02			season 010			Season 470
			# season 3004			season 4			season 05			season 090			Season 5800
			season_match='[S|s]eason.([1-9]{1}[0]{3}|[1-9]{1}[0]{1,2}[1-9]{1,2}|[0]{1}[1-9]{1}[0]{1}|[1-9]{1,2}[0]{1,2}|[1-9]{1,4}|[0]{1,2}[1-9]{1})';
			if [[ "$clean_folder" =~ $season_match ]]; then
				season_count=${clean_folder#* }
				season_count=$(echo ${season_count} | cut -d ' ' -f 1)
				
				if [[ "$season_count" -le "9999" ]]; then
					season_count_total=$(leading_zero_fill 4 "$season_count")
				fi
				if [[ "$season_count" -le "999" ]]; then
					season_count_total=$(leading_zero_fill 3 "$season_count")
				fi
				if [[ "$season_count" -le "99" ]]; then
					season_count_total=$(leading_zero_fill 2 "$season_count")
				fi
			else
				season_count_total=$(leading_zero_fill 2 "$season_numb")
			fi

			total_season_count=$(find ./ -type d -regextype posix-extended -regex './[S|s]eason.([1-9]{1}[0]{3}|[1-9]{1}[0]{1,2}[1-9]{1,2}|[0]{1}[1-9]{1}[0]{1}|[1-9]{1,2}[0]{1,2}|[1-9]{1,4}|[0]{1,2}[1-9]{1})([[:space:]]\([0-9]{2,}\-[0-9]{2,}\))?([[:space:]]\([0-9]{4,}\))?' -printf x | wc -c)

			((season_numb++))
			
			cd "$season_folder"

			# Get all video files in the season folder.
			find ./ -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '.mov' -o -iname '*.avi' -o -iname '*.wmv' -o -iname '*.flv' -o -iname '*.f4v' -o -iname '*.mkv' -o -iname '*.webm' -o -iname '*.m4v' -o -iname '*.3gp' -o -iname '*.3g2' -o -iname '*.ogv' -o -iname '*.vob' -o -iname '*.avchd' -o -iname '*.mpg' -o -iname '*.mpeg2' -o -iname '*.mxf' \) -print0 | 
			sort -z | 
			while read -r -d '' main_folder; do

				another_simple_renamer true "$main_folder" "$season_count_total" "$new_show_name" "$episode_numb" "$platform" "$check_season" "$rename_status" "$mover_status" "$single_folder" "$move_folder" "$total_season_count" "$season_numb"

			done # end show search

			# Change back to the shows main folder.
			cd ../

		done #end season search

		# Change back to root directory of the array.
		cd "$single_folder"

	done
done

echo Done!

sleep 2
exit 1

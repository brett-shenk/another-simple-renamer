# Another Simple Renamer

The primary goal is to automate the process of renaming video files. It can be ran as a process / script / job on a server or your computer in the background. It's default configuration doesn't use many resources. There are no dependencies. It works on Linux as well as Windows computers. Mac support is unknown at the time.

While Plex is the expected platform to be used, support for others like Kodi needs tested. The full list is below as well as the complete list of video files supported. By default it will only include video folders that contain `[]` in the name. Text can be inside the brackets and their position can be in front of or behind the show name.

<br>

## Features
- [x] Supported platforms:
  - [x] Plex
- [x] Supported video file types:  
  - mp4, mov, avi, wmv, flv, f4v, mkv, webm, m4v, 3gp, 3g2, ogv, vob, avchd, mpg, mpeg2, mxf
- [x] Extras don't get renamed by default. Such as:
  - File Names that contain: 
    - -behindthescenes, -deleted, -featurette, -interview, -scene, -short, -other, -clip, -deletedscene, -extra
    - -trailer, .trailer, _trailer, -sample, .sample, _sample
  - Folders Named:
    - season 0, Season 00
    - Specials, extras
  - As for why, currently unable to account for episodes not being in order.
- [x] Multiple video folder paths.
- [x] Multiple seasons & videos.
- [x] Movies or tv shows in the video folder.
- [x] It will try to detect the current season number. Supports season folders with the following format:
  - Season 1, Season 01, Season 001
  - Season 1997
  - Season 1 (1996-97)
  - Season 01 (1996-1997)
  - Season 01 (96-97)
  - Season 01 (1997)
- [x] Supports episode count up to: `9999`
  - Leading zero fill counter, based on the amount of videos in the current folder.
- [x] Option for finding video files that don't contain: `[]`
- [x] Check new file name doesn't already exist first and it's not currently in use.
  - [x] Make sure series folder isn't renamed if a file in it is in use.
- [x] Option to reset file permissions and owner.
- [x] Option to move completed files to a new folder.

<br>

## Future Updates
- [ ] Supported platforms:
  - [ ] Kodi
  - [ ] Emby
  - [ ] Jellyfin
- [ ] support renaming subtitle files.
- [ ] TV Show episodes split across multiple files.
- [ ] TV Show multiple episodes in a single file.
- [ ] Multi-edition movies?
- [ ] Multi-version movies?

<br>

## Usage

Type the name of the script, below, in a terminal. Need to be in the folder that contains the script.

`./another-simple-renamer.sh`

<br>

Open the script, it contains the following variables:

<dl>
	<dt>$rename_status</dt>
	<dd>Set to false to test the results. Set to true to rename.</dd>
	<dd>Boolean. [true, false]</dd>
	<dt>$path</dt>
	<dd>The full folder paths to be searched. Key is only required if the mover is enabled. When both options are enabled the key in the $path gets compared to the key in the $mover_path.</dd>
	<dd>array</dd>
	<dt>$mover_status</dt>
	<dd>Enable or disable moving the video files as the last step.</dd>
	<dd>Boolean. [true, false]</dd>
	<dt>$mover_path</dt>
	<dd>Only required if $mover_status is set to true. See example below.</dd>
	<dd>array</dd>
	<dt>$main_match</dt>
	<dd>Regex for folders that will be included in the renaming process.</dd>
	<dd>string</dd>
	<dt>$reset_perms</dt>
	<dd>Weather the video permissions are reset to allow full access. Want different permissions? Here's a <a href="https://linuxhandbook.com/linux-file-permissions/#using-chmod-in-absolute-mode" target="_blank">link that should help</a>.</dd>
	<dd>Boolean. [true, false]</dd>
	<dt>$reset_owner</dt>
	<dd>Weather the video's owner is reset to the default, nobody.</dd>
	<dd>Boolean. [true, false]</dd>
</dl>

<br>

## Examples

	/Movies
  		/Avatar (2009) [720]
    		Avatar (2009).mkv
	/TV Shows
		/Doctor Who (1963) [720]
			/Season 01
				Doctor Who (1963) - s01e01.mp4
				Doctor Who (1963) - s01e02.mp4
		/From the Earth to the Moon (1998) [720]
			/Season 01
				From the Earth to the Moon (1998) - s01e01.mp4
				From the Earth to the Moon (1998) - s01e02.mp4
		/[720] Grey's Anatomy (2005)
			/Season 1
				Grey's Anatomy (2005) - s01e01.avi
				Grey's Anatomy (2005) - s01e02.avi
				Grey's Anatomy (2005) - s01e03.mp4
		/Mythbusters [720]
			/Season 2003
				Mythbusters - S2003e01.mkv
				Mythbusters - S2003e02.mkv

In the example below, the "dub" in $path will get moved to the $mover_path with "dub". Same for the "sub".

	declare -A path=(
		["dub"]="/mnt/user/download/anime-dub/", 
		["sub"]="/mnt/user/download/anime-sub/"
	)

	declare -A mover_path=(
		["dub"]="/mnt/user/media/anime-dub/", 
		["sub"]="/mnt/user/media/anime-sub/"
	)

<br>

## Bugs & Feature Requests

Please provide as much detail as possible for bug reports. Features / pull requests will be considered as long as it supports the primary goal.

<br>

<hr>

### [Changelog](./changelog.md)

### [License](./license.txt)

This is covered under the [Creative Commons Attribution 4.0](https://choosealicense.com/licenses/cc-by-4.0/) license.
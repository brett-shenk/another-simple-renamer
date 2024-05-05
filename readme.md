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

<br>

## Future Updates
- [ ] Supported platforms:
  - [ ] Kodi
  - [ ] Emby
  - [ ] Jellyfin
- [ ] support renaming subtitle files.
- [ ] Option to move completed files to a new folder.
- [ ] TV Show episodes split across multiple files.
- [ ] TV Show multiple episodes in a single file.
- [ ] Multi-edition movies?
- [ ] Multi-version movies?

<br>

## Usage

Type the name of the script, below, in a terminal. Need to be in the folder that contains the script.

`./another-simple-renamer.sh`

<br>

Open the script, it contains the following variables.

<dl>
	<dt>rename_status</dt>
	<dd>Mostly for development / testing. Should the files be renamed? [true, false]</dd>
	<dd>Boolean</dd>
	<dt>path</dt>
	<dd>The full folder paths to be searched.</dd>
	<dd>array | string</dd>
	<dt>main_match</dt>
	<dd>Regex for folders that will be included in the renaming process.</dd>
	<dd>string</dd>
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

<br>

## Bugs & Feature Requests

Please provide as much detail as possible for bug reports. Features / pull requests will be considered as long as it supports the primary goal.

<br>

<hr>

### [Changelog](./changelog.md)

### [License](./license.txt)

This is covered under the [Creative Commons Attribution 4.0](https://choosealicense.com/licenses/cc-by-4.0/) license.
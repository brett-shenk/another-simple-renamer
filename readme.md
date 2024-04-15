# Another Simple Renamer

The primary goal is to automate the process of renaming video files. It can be ran as a process / script / job on a server or your computer in the background. It's default configuration doesn't use many resources. There are no dependencies. It works on Linux as well as Windows computers. Mac support is unknown at the time.

While Plex is the expected platform to be used, other's are supported. The full list is below as well as the complete list of video files supported. By default it will only include video folders that contain `[]` in the name. Text can be inside the brackets and their position can be in front of or behind the show name.

<br>

## Features and Future Updates
- [x] Supported platforms:
  - [x] Plex
  - [ ] Kodi
  - [ ] Emby
  - [ ] Jellyfin
- [x] Supports various video file types:  
  - mp4, mov, avi, wmv, flv, f4v, mkv, webm, m4v, 3gp, 3g2, ogv, vob, avchd, mpg, mpeg2, mxf
- [x] Extras don't get renamed. Such as:
  - Files that contain: -behindthescenes, -deleted, -featurette, -interview, -scene, -short, -other, -trailer, .trailer, _trailer, -sample, .sample, _sample, -clip, -deletedscene, -extra
  - `/extras/`, `/season 0/`, `/Season 00/`, `/Specials/`
  - As for why, currently unable to account for episodes not being in order.
- [x] Multiple video folder paths
- [x] Multiple seasons & videos
- [x] Movies or tv shows in the video folder
- [x] Supports season folders: `/Season 01/`
- [x] Supports episode count up to: `9999`
  - Leading zero fill counter, based on the amount of videos in the current folder.
- [ ] Detect season number on folder to support a single season being added to a current show
- [ ] Option for finding video files that don't contain `[]`
- [ ] Subtitles support
- [ ] Multi-edition?
- [ ] Multi-version?
- [ ] Check if file exists first?

<br>

## Usage

Type the name of the script, below, in a terminal. Need to be in the folder that contains the script.

`./ another-simple-renamer.sh`

Open the script, it contains the following variables.

<dl>
	<dt>rename_status</dt>
	<dd>Mostly for development / testing. Should the files be renamed? [true, false]</dd>
	<dd>Boolean</dd>
	<dt>path</dt>
	<dd>The full folder paths to be searched.</dd>
	<dd>array | string</dd>
</dl>

<br>

## Bugs & Feature Requests

Please provide as much detail as possible for bug reports. Features / pull requests will be considered as long as it supports the main goal.

## License

This is covered under the [Creative Commons Attribution 4.0](https://choosealicense.com/licenses/cc-by-4.0/) license.
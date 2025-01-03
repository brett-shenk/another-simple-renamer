# Changelog

Version - Date (YYYY-MM-DD)

<br>

## 0.10.0 (2024-11-17)
- Support for Windows.
  - At the moment, skips checking if the video file is currently in use.
- Update script console output to always output something.
- Fix bug with changelog format.
- Indicate where to edit.
- Add comment of some examples for what season folders are matched.
- Remove duplicate code by reformatting the core work to be a function.

<br>

## 0.9.0 (2024-08-30)
- Convert `$path` array to associative array.
- Loop over the `$path` keys instead. Then get the value for the current key.
- Add support for multiple output folders. The `$mover_path` and `$path` keys are compared together for where it should get moved to.
- Fix issue with changing directories that were created from implementing the mover.
- Check if the video folder should to be renamed or moved before doing so.
- update script console output.
- Fix issue with TV Show episode counter not properly updating.
- Update script comments.
- Update readme.

<br>

## 0.8.2 (2024-05-13)
- Separate permissions and owner to be separate settings.
- relocate echo for testing purposes.
- skip main folder if it happens to get included. `./`
- Add comment about how to include all folders.
- Update readme
- Update comments

<br>

## 0.8.1 (2024-05-05)
- Fix main folder rename not working.

<br>

## 0.8.0 (2024-05-05)
- Add changelog.
- Update readme.
- Update comments.
- Change main folder search logic to regex to support wider search parameters other than the default.
- Detect season number on folders inside a show to support a single season being added to a current show.
  - If the season number isn't found, it will start a new season counter at 01.
- Check if the new video file name or new folder name doesn't already exist. A message will be in the console log if it happens.
- Skip videos that are currently in use by other programs. A message will be in the console log if it happens.
- Relocate main folder rename to support the new features.
- Small format update to the console log if `$rename_status` is set to false for nicer output in large libraries.
- Add option to reset permissions and owner of the files in the search.d
- Support for Kodi, Emby and Jellyfin needs to be confirmed. Needed changes should be noted.
- Rewrote `$video_count` to get all videos and another to only get the extras then do some math. In some edge cases, excluding resulted in odd results.
- Update `$file_ending` to get the last instance to support larger file names.
- Update `$season_match` to support more cases.
- Remove temporary stop.

<br>

## 0.7.0 (2024-04-14)
- Initial release.
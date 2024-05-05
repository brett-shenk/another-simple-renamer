# Changelog

Version - Date (YYYY-MM-DD)

<br>

## 0.8.0 (2024-05-00)
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
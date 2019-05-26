# Changelog

## [Unreleased] - TBD
### Add
- Move Album:
  - Sanity check: Compare # of items in playlist vs music files in folder.
  - Detect when Foobar2000 is off (not just Paused/Stopped) and Exit.

### Change
- Improve scrolling hotkey logic to be more efficient, or limit scrolling updates.

### Fix
- Move Album:
  - Move album two levels deep does not remove empty parent folder.

## [2.2.0] - 2019-05-25
### Changed
- Move Album:
  - RunWait() instead of Run().
  - ExitApp() uses exit codes for errors.
- First level indentation added for hotkeys & subroutines.

### Fixed
- Move Album:
  - ChooseString fixed and genre selection is working reliably now.
- Using logical comparison operators for if() statements.
- LoopGenre() includes return statement.

## [2.1.0] - 2019-05-24
### Added
- Move Album:
  - Genre selection confirmation window appears before move, with ability to cancel.
  - Checks GetSongInfo() and attempts to fix missing info by starting/stopping music.
    - Terminates if information still cannot be obtained.
  - Move album trigger workflow opens containing folder (Ctrl+Alt+o) prior to moving.
  - Move album trigger workflow starts next song after move completes.
  - Move album window now has title. Removed minimize/maximize buttons.

### Fixed
- Move Album:
  - Closing window via "x" close button now properly destroys GUI window and exits the app.

## [2.0.1] - 2019-05-21
### Added
- Move album trigger automatically clears missing/removed songs from Foobar2000 after has completed.

### Fixed
- Move album trigger improvements.

## [2.0.0] - 2019-05-21
### Added
- New Feature: Move Album
  - GUI window support for moving albums to second temp directory genre folder with hotkey.
    - Bug: ChooseString doesn't choose the correct selection when input of < 2 char is received.
  - Usage: Ctrl+Alt+m

### Changed
- Moved shared functions to separate func.ahk in lib folder.
- Better exception handing.
- Many other updates.

## [1.1.2] - 2019-05-13
### Fixed
- Fixed MaxHotkeysPerInterval warning when scrolling using touch pad.
  - To do: Improve scrolling hotkey logic to be more efficient, or limit scrolling updates.

## [1.1.1] - 2019-05-13
### Changed
- Standardized naming & case conventions.
  
## [1.1.0] - 2019-05-13
### Fixed
- Scroll detection:
  - Pauses the speed times if mouse scroll is detected in last 3 seconds.

### Added
- Changelog

## [1.0.0] - 2019-05-12
### Added
- First version commit.

[Unreleased]: https://github.com/skupjoe/foo-playback-helper/compare/v2.2.0...HEAD
[2.2.0]: https://github.com/skupjoe/foo-playback-helper/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/skupjoe/foo-playback-helper/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/skupjoe/foo-playback-helper/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.2...v2.0.0
[1.1.2]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/skupjoe/foo-playback-helper/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/skupjoe/foo-playback-helper/compare/a2bfe1c...v1.0.0
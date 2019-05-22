# Changelog

## [Unreleased] - TBD
### Change
- Add a genre selection confirmation window.
- Improve scrolling hotkey logic to be more efficient, or limit scrolling updates.

### Fix
- Re-implement ChooseString mechanism or come up with better workaround.

## [2.0.1] - 2019-05-21
### Added
= Move album trigger automatically clears missing/removed songs from Foobar2000 after has completed.

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

[Unreleased]: https://github.com/skupjoe/foo-playback-helper/compare/v2.0.1...HEAD
[2.0.1]: https://github.com/skupjoe/foo-playback-helper/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.2...v2.0.0
[1.1.2]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/skupjoe/foo-playback-helper/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/skupjoe/foo-playback-helper/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/skupjoe/foo-playback-helper/compare/a2bfe1c...v1.0.0
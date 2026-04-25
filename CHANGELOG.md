# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-04-24

### Added
- Initial extraction. `CgminerTestSupport::FakeCgminer` (in-process TCP
  server) and `CgminerTestSupport::Fixtures` (canned wire-format JSON
  responses) consolidated from the duplicated `spec/support/` copies in
  `cgminer_api_client`, `cgminer_monitor`, and `cgminer_manager`.
- Write-verb fixtures (`RESTART_OK`, `QUIT_OK`, `ZERO_OK`, `SAVE_OK`)
  added to `Fixtures::DEFAULT` so test fakes respond to scheduled
  restarts, quit, zero, and save without falling through to "Invalid
  command".
- `exe/fake_cgminer` standalone runner; replaces
  `cgminer_api_client/script/fake_cgminer`.

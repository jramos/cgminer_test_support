# cgminer_test_support

Shared test doubles for the [cgminer](https://github.com/jramos/cgminer_api_client)
Ruby ecosystem.

- `CgminerTestSupport::FakeCgminer` — in-process TCP server that speaks
  the cgminer JSON API. Used by integration specs and manual sandboxes.
- `CgminerTestSupport::Fixtures` — canned JSON wire-format responses
  for the read verbs (`summary`, `devs`, `pools`, `stats`,
  `summary+pools`), the access-control verbs (`privileged`,
  `addpool`), and the write verbs (`restart`, `quit`, `zero`, `save`).

## Use from a sibling gem's `Gemfile`

```ruby
group :development, :test do
  gem 'cgminer_test_support',
      git: 'https://github.com/jramos/cgminer_test_support.git',
      tag: 'v0.1.0',
      require: false
end
```

Then in `spec/spec_helper.rb`:

```ruby
require 'cgminer_test_support'
```

## Standalone sandbox

```sh
bundle exec fake_cgminer 4028
# fake cgminer listening on 127.0.0.1:4028
# commands available: addpool, devs, pools, privileged, summary, summary+pools, stats, restart, quit, zero, save
```

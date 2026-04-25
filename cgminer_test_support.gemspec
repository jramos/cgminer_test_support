# frozen_string_literal: true

require_relative 'lib/cgminer_test_support/version'

Gem::Specification.new do |spec|
  spec.name        = 'cgminer_test_support'
  spec.version     = CgminerTestSupport::VERSION
  spec.authors     = ['Justin Ramos']
  spec.email       = ['justin.ramos@gmail.com']
  spec.summary     = 'Shared test doubles for the cgminer Ruby ecosystem'
  spec.description = 'Provides FakeCgminer (in-process TCP server speaking the cgminer JSON API) ' \
                     'and Fixtures (canned wire responses) used by cgminer_api_client, cgminer_monitor, ' \
                     'and cgminer_manager.'
  spec.homepage    = 'https://github.com/jramos/cgminer_test_support'
  spec.license     = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/jramos/cgminer_test_support',
    'changelog_uri' => 'https://github.com/jramos/cgminer_test_support/blob/master/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/jramos/cgminer_test_support/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir[
    'lib/**/*.rb',
    'exe/*',
    'README.md',
    'CHANGELOG.md',
    'LICENSE.txt'
  ]
  spec.bindir      = 'exe'
  spec.executables = ['fake_cgminer']
  spec.require_paths = ['lib']
end

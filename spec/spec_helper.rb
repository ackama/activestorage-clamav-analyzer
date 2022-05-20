# frozen_string_literal: true

require 'bundler/setup'
require 'tmpdir'
require 'active_storage/clamav/analyzer'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  ##
  # Support running specs against a single daemonized version
  # of ClamAV. This is _significantly_ faster than running each spec
  # since this requires ClamAV to setup and tear down itself, which
  # can take several seconds per test.
  config.before(:suite) do
    next unless ENV['WITH_CLAMD'] == 'true'

    puts 'Starting ClamD'
    `clamd` # <- Starts in daemon mode then exits

    # Run checks against clamd
    ActiveStorage::ClamAV::Analyzer.command = 'clamdscan'
  end

  config.after(:suite) do
    next unless ENV['WITH_CLAMD'] == 'true'

    puts 'Stopping ClamD'
    `kill -15 $(pgrep clamd)`
  end
end

# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'activestorage-clamav-analyzer'
  spec.version       = '0.1.0'
  spec.authors       = ['Josh McArthur']
  spec.email         = ['joshua.mcarthur@gmail.com']
  spec.required_ruby_version = '>= 2.5.0'

  spec.summary       = '
    Performs anti-virus scans on ActiveStorage::Blob objects using ClamAV'
  spec.description   = '
    Add ActiveStorage Analyzer class to perform ClamAV virus scans on
    ActiveStorage::Blob objects. Supports ClamAV daemon mode, custom arguments
    and callbacks on detection.'
  spec.homepage      = 'https://github.com/ackama/activestorage-clamav-analyzer'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_dependency 'activestorage'
  spec.metadata['rubygems_mfa_required'] = 'true'
end

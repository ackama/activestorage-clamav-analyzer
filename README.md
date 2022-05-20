# ActiveStorage::ClamAV::Analyzer

[![Ruby](https://github.com/ackama/activestorage-clamav-analyzer/actions/workflows/ruby.yml/badge.svg)](https://github.com/ackama/activestorage-clamav-analyzer/actions/workflows/ruby.yml)

[![Gem Version](https://badge.fury.io/rb/activestorage-clamav-analyzer.svg)](https://badge.fury.io/rb/activestorage-clamav-analyzer)

This gem packages an analyzer to perform ClamAV virus scans on uploaded ActiveStorage::Blob objects, adding the results of the scan to the blob metadata.

The actual analyzer is very simple, and can be found in `lib/active_storage/clamav/analyzer` if you would prefer to just drop this in `app/analyzers` in your codebase and prepend it to the analyzers list yourself.

## Installing ClamAV

Ensure you have ClamAV installed. This gem uses these commands, but does not
set them up if they are missing. On your path you should have:

- `clamav`
- `clamscan`

On most platforms, you can install ClamAV with the package name:

- Mac OS: `brew install clamav` (Further setup steps are necessary with Homebrewed ClamAV, see https://gist.github.com/mendozao/3ea393b91f23a813650baab9964425b9)
- Debian/Ubuntu: `apt install clamav`

There are plenty of other installation methods and platforms available. More information about these is available on [ClamAV's website](https://docs.clamav.net/manual/Installing.html)

You can also run ClamAV scans in a Docker container. The [ClamAV documentation] has [an installation page](https://docs.clamav.net/manual/Installing/Docker.html) dedicated to this. While you will have to tune `ActiveStorage::ClamAV::Analyzer.command` for this, it should work with this gem.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-clamav-analyzer', require: "active_storage/clamav/analyzer"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activestorage-clamav-analyzer

This gem will automatically add itself to the analyzer pipeline and run across any
supported image files. If you wish to control the precise analyzer order, you can
manipulate the `ActiveStorage.analyzers` array.

## Usage

This gem automatically adds itself to the analysis pipeline, simply ensure that analysis is run on your uploaded files.

To manually analyze a particular blob, simply grab an attachment and pass the
blob directly to the analyzer:

```ruby
ActiveStorage::ClamAV::Analyzer.new(ActiveStorage::Attachment.first.blob).metadata
 =>  {
    "analyzed"=>true,
    "clamav": {
        "detection": true,
        "output": "test.txt: Eicar-Signature FOUND\n\n-------" #...
    }}
```

## Recipes

#### Scan with ClamD

`clamscan` is the default command, but starts up ClamAV from scratch each time it is run, which takes several seconds.
Using `clamd` is much faster, but requires you to have started `clamd` ahead of time.

An example of the speedups that are possible:

- `clamscan README.md 9.68s user 0.36s system 96% cpu 10.400 total`
- `clamdscan README.md 0.01s user 0.00s system 36% cpu 0.026 total`

If your infrastructure set up allows you to run `clamd`, you can adjust the command to use `clamdscan`, which will
scan files in a fraction of the time:

```ruby
# config/initializers/active_storage.rb
ActiveStorage::ClamAV::Analyzer.command = "clamdscan"
```

#### Scan with a Docker container

ClamAV has comprehensive documentation on [how to scan files in a Docker container](https://docs.clamav.net/manual/Installing/Docker.html).
If you'd like to do this yourself using the ClamAV analyzer, that's no problem! You'll need to build a custom
command to mount the blob's tempfile into your container to get the result. `ActiveStorage::ClamAV::Analyzer.command` accepts anything
that responds to `#call`, so you can customise your command:

```ruby
# config/initializers/active_storage.rb

clamav_command = (tempfile) -> { "docker run --rm -v #{tempfile.path}:#{tempfile.path} clamav/clamav clamscan" }
ActiveStorage::ClamAV::Analyzer.command = clamav_command
```

#### Report detections as an exception

The `on_detection` setting on `ActiveSupport::ClamAV::Analyzer` can be used to take some
action when a detection occurs. Your application may not have a defined code path for virus
detections, but you still want to know when it happens. You can use `on_detection` for this
to report detections to your exception monitoring tool of choice.

```ruby
ActiveStorage::ClamAV::Analyzer.on_detection = lambda do |blob|
  err = StandardError.new("Virus detected in ActiveStorage::Blob ##{blob.id}")
  ExceptionMonitoringService.capture_exception(err)
end
```

#### Remove blobs that have a detection

This analyzer records detections, but by default takes no action. Destroying blobs from a library could surprise some
users, stops further analyzers and processing from running, and also would prevent any investigation of the blob, who uploaded it, and what the exact detection is.

The analyzer does however call a callable (Proc, lambda, etc) when a detection occurs, passing the blob - so it's very simple
to remove the blob automatically when a detection occurs.

```ruby
ActiveStorage::ClamAV::Analyzer.on_detection = (blob) -> { blob.destroy }
```

You can use the same technique to take some other action - perhaps quarantine the blob in some way (make it inactive), or
add it to a moderation or alert queue.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the lint checks and tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ackama/activestorage-clamav-analyzer.

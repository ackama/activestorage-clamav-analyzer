# ActiveStorage::ClamAV::Analyzer

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
    "clamav_detection": true,
    "clamav_raw_summary": "test.txt: Eicar-Signature FOUND\n\n-------" #...
    }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the lint checks and tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ackama/activestorage-clamav-analyzer.

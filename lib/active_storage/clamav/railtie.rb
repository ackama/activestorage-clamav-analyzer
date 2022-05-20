# frozen_string_literal: true

module ActiveStorage
  module ClamAV
    ##
    # Adds the analyser to the list of ActiveStorage analyzers
    # when the Rails app is configured
    class Railtie < Rails::Railtie
      config.active_storage.analyzers.prepend ActiveStorage::ClamAV::Analyzer
    end
  end
end

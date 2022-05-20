# frozen_string_literal: true

require 'open3'
require 'active_storage'
require 'active_storage/analyzer/image_analyzer'

module ActiveStorage
  module ClamAV
    ##
    # Uses ClamAV to perform an antivirus scan on the ActiveStorage::Blob,
    # taking action if a detection occurs and otherwise recording the scan
    # results as metadata.
    #
    # This analyzer requires that ClamAV is installed, but otherwise makes the
    # command and flags available via accessors on this module.
    class Analyzer < ActiveStorage::Analyzer
      ##
      # Configure the command to run when analyzing blobs. This can either be a
      # string of command or command + args, or can be a callable object.
      # If callable, it will be called before analysing, and will pass an
      # instance of a tempfile. This is useful for using ClamAV via things
      # like Docker, when you may want to mount the tempfile into a container
      # for scanning.
      mattr_accessor :command, default: 'clamscan'

      ##
      # Configure a callable to run when ClamAV returns a non-zero status
      # indicating a virus was detected. The callable receives the blob and
      # can take action to quarantine or remove the blob record, send an alert,
      # or some other action.
      mattr_accessor :on_detection, default: ->(blob) {}

      ##
      # All blobs can be virus scanned
      def self.accept?
        true
      end

      def metadata
        { clamav: download_blob_to_tempfile(&method(:perform_virus_scan)) }
      end

      private

      def run_command(*args)
        command = if self.command.respond_to?(:call)
                    self.command.call(*args)
                  else
                    self.command
                  end

        stdout, _stderr, status = Open3.capture3(command, *args)
        status == 127 && \
          raise("#{command} not found. Is it installed and available on PATH?")

        [stdout, status]
      end

      def perform_virus_scan(tempfile)
        output, status = run_command(tempfile.path)
        on_detection.call(blob) rescue nil unless status.success? # rubocop:disable Style/RescueModifier

        {
          detection: !status.success?,
          output: output
        }
      end
    end
  end
end

require 'active_storage/clamav/railtie' if defined?(Rails)

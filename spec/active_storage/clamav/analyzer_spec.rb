# frozen_string_literal: true

require 'spec_helper'
require 'pry'

RSpec.describe ActiveStorage::ClamAV::Analyzer do # rubocop:disable Metrics/BlockLength
  let(:blob) { fake_blob(io: File.open('spec/fixtures/nodetection.txt')) }

  describe '.metadata' do # rubocop:disable Metrics/BlockLength
    it 'returns expected metadata for a detected virus' do
      blob = fake_blob(io: File.open('spec/fixtures/detection.txt'))
      metadata = described_class.new(blob).metadata
      expect(metadata[:clamav][:detection]).to eq true
      expect(metadata[:clamav][:output]).to include(
        'spec/fixtures/detection.txt: Eicar-Signature FOUND'
      )
    end

    it 'returns expected metadata for a safe file' do
      blob = fake_blob(io: File.open('spec/fixtures/nodetection.txt'))
      metadata = described_class.new(blob).metadata
      expect(metadata[:clamav][:detection]).to eq false
      expect(metadata[:clamav][:output]).to include(
        'spec/fixtures/nodetection.txt: OK'
      )
    end

    it 'allows a custom command to be used' do
      original_command = ActiveStorage::ClamAV::Analyzer.command
      begin
        ActiveStorage::ClamAV::Analyzer.command = 'ls'
        blob = fake_blob(io: File.open('spec/fixtures/detection.txt'))
        metadata = described_class.new(blob).metadata
        expect(metadata[:clamav][:detection]).to eq false
        expect(metadata[:clamav][:output]).to eq(
          "spec/fixtures/detection.txt\n"
        )
      ensure
        ActiveStorage::ClamAV::Analyzer.command = original_command
      end
    end

    it 'allows a custom on_detection proc to be used' do
      original_on_detection = ActiveStorage::ClamAV::Analyzer.on_detection
      begin
        called = false

        ActiveStorage::ClamAV::Analyzer.on_detection =
          ->(_blob) { called = true }
        blob = fake_blob(io: File.open('spec/fixtures/detection.txt'))

        metadata = described_class.new(blob).metadata
        expect(called).to eq true
        expect(metadata[:clamav][:detection]).to eq true
      ensure
        ActiveStorage::ClamAV::Analyzer.on_detection = original_on_detection
      end
    end
  end

  private

  def fake_blob(io:)
    dbl = double
    allow(dbl).to receive(:open).and_yield(io)

    dbl
  end
end

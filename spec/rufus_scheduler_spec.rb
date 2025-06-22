# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rufus::Scheduler integration' do
  it 'does not start the scheduler when SKIP_SCHEDULER is true' do
    expect(ENV['SKIP_SCHEDULER']).to eq('true')
    # Optionally, check that no scheduler thread is running
    expect(Thread.list.none? { |t| t[:rufus_scheduler] }).to be true
  end

  it 'starts the scheduler when SKIP_SCHEDULER is not set (subprocess integration test)' do
    require 'tempfile'
    script = <<~RUBY
      require 'rufus-scheduler'
      started = false
      scheduler = Rufus::Scheduler.new
      scheduler.every '1s' do
        started = true
        puts 'scheduled!'
        exit 0
      end
      sleep 2
      exit 1 unless started
    RUBY
    Tempfile.create(['rufus_test', '.rb']) do |file|
      file.write(script)
      file.flush
      output = `SKIP_SCHEDULER= ruby #{file.path}`
      expect(output).to include('scheduled!')
    end
  end
end

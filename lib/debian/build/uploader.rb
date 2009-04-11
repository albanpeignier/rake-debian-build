require 'fileutils'

module Debian::Build

  class Uploader
    include FileUtils

    @@default = Uploader.new
    def self.default; @@default end

    # TODO nickname could be used to determinate incoming and host
    attr_accessor :nickname
    attr_accessor :incoming, :host

    def initialize
      self.incoming = '/var/lib/debarchiver/incoming'
    end

    def lock(&block)
      raise "No defined host, can't create lock file in ssh" unless host

      begin
        sh "ssh #{host} touch #{lock_file}"
        yield
      ensure
        sh "ssh #{host} rm -f #{lock_file}"
      end
    end

    def lock_file
      File.join(incoming, "debarchiver.lock")
    end

    def dupload(*changes_files)
      options = ['-t', nickname] if nickname
      sh *["dupload", options, changes_files].flatten.compact
    end

    def rsync(target_directory, *files)
      sh "rsync -av #{files.join(' ')} #{host}:#{incoming}/#{target_directory}"
    end

  end

end

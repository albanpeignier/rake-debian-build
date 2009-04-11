module Debian::Build
  module BuildDirectoryMethods

    @@build_directory = '/var/tmp/debian'

    def build_directory=(directory)
      @@build_directory = directory
    end

    def build_directory
      @@build_directory or '/var/tmp/debian'
    end

  end
end

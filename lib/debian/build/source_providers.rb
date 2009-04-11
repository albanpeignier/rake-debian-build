require 'fileutils'
require 'uri'

module Debian::Build

  class TarballSourceProvider
    include FileUtils
    include Debian::Build::HelperMethods

    def initialize(url)
      @url = url
    end

    def retrieve(package)
      PackageRetriever.new(@url, package).retrieve
    end

    class PackageRetriever
      include FileUtils
      include Debian::Build::HelperMethods

      attr_reader :package
      
      def initialize(url, package)
        @url, @package = url, package
      end
      
      def retrieve
        get tarball_url
        uncompress tarball_name
        prepare_orig_tarball
      end

      def prepare_orig_tarball
        if tarball_name.match /bz2$/ 
          sh "bunzip2 -c #{tarball_name} | gzip -c > #{orig_tarball_name}" unless File.exists?(orig_tarball_name)
        else
          sh "ln -fs #{tarball_name} #{orig_tarball_name}"
        end
      end

      def tarball_url
        unless @tarball_url
          def package.get_binding
            binding
          end

          @tarball_url = eval( '"' + @url + '"', package.get_binding)
        end

        @tarball_url
      end

      def tarball_name
        File.basename URI.parse(tarball_url).path
      end

      def orig_tarball_name
        package.orig_source_tarball_name
      end

    end

  end

  class AptSourceProvider
    include FileUtils

    def retrieve(package)
      sh "apt-get source #{package.name}"
    end

  end

end

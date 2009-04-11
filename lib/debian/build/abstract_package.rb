require 'rake/tasklib'

module Debian::Build

  @packages = []

  def self.packages
    @packages
  end

  class AbstractPackage < Rake::TaskLib
    include HelperMethods
    extend BuildDirectoryMethods

    attr_reader :name
    attr_accessor :package, :exclude_from_build

    def initialize(name)
      @name = @package = name

      init
      yield self if block_given?
      define

      Debian::Build.packages << name.to_sym
    end
    
    def init
    end

    def default_platforms
      unless exclude_from_build
        Platform.all
      else
        Platform.all.reject do |platform|
          platform.to_s.match exclude_from_build
        end
      end
    end

  end
end

module Debian::Build
  class Distribution
    extend BuildDirectoryMethods

    attr_reader :flavor, :distribution

    def initialize(flavor, distribution)
      @flavor = flavor
      @distribution = distribution.to_sym
    end

    def self.all
      @@all ||= debian_distributions + ubuntu_distributions
    end

    def self.each(&block)
      all.each &block
    end

    def self.debian_distributions
      @@debian_distributions ||= 
        %w{stable testing unstable}.collect { |distribution| Distribution.new(:debian, distribution) }
    end

    def self.ubuntu_distributions
      @@ubuntu_distributions ||= 
        %w{hardy intrepid}.collect { |distribution| Distribution.new(:ubuntu, distribution) }
    end

    def source_result_directory
      File.expand_path "#{Platform.build_directory}/sources/#{distribution}"
    end

    @@mirrors = { :debian => "http://ftp.debian.org/debian", :ubuntu => 'http://archive.ubuntu.com/ubuntu' }

    def self.mirrors=(mirrors)
      @@mirrors.update(mirrors)
    end

    def mirror
      @@mirrors[flavor]
    end

    def ubuntu?
      flavor == :ubuntu
    end

    def unstable?
      [ :unstable, :intrepid ].include? distribution
    end
    
    @@local_names = { :stable => 'lenny', :testing => 'squeeze', :intrepid => 'ubuntu', :hardy => 'hardy' }
    def local_name
      @@local_names[distribution]
    end

    def to_s
      distribution.to_s
    end

    def task_name
      to_s
    end

  end
end

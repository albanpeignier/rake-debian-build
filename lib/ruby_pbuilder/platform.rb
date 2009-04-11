module RubyPbuilder
  class Platform
    extend BuildDirectoryMethods

    attr_reader :architecture

    def method_missing(method, *args, &block)
      if @distribution.respond_to? method
        @distribution.send method, *args
      else
        super
      end
    end


    def initialize(distribution, architecture)
      @distribution = distribution
      @architecture = architecture
    end

    def self.supported_architectures
      %w{i386 amd64}
    end

    def self.all
      @@all ||= 
        Distribution.all.collect do |distribution|
        supported_architectures.collect { |architecture| Platform.new(distribution, architecture) }
      end.flatten
    end

    def self.each(&block)
      all.each &block
    end

    def build_result_directory
      File.expand_path "#{Platform.build_directory}/binaries/#{distribution}/#{architecture}"
    end

    def pbuilder_base_file
      "/var/cache/pbuilder/base-#{distribution}-#{architecture}.tgz"
    end

    def pbuilder_enabled?
      File.exists? pbuilder_base_file
    end

    def pbuilder(options = {})
      PBuilder.new do |p|
        p[:basetgz] = pbuilder_base_file
        p[:othermirror] = "'deb file:#{build_result_directory} ./'"
        p[:bindmounts] = p[:buildresult] = build_result_directory
        p[:distribution] = distribution
        p[:hookdir] = default_hooks_directory

        # to use i386 on amd64 architecture
        p[:debootstrapopts] = [ "--arch=#{architecture}" ]
        p[:debbuildopts] = [ "-a#{architecture}", '-b' ]

        p[:mirror] = mirror

        if flavor == :ubuntu
          # cdebootstrap fails with ubuntu
          p[:components] = "'main universe'"
          p[:debootstrap] = 'debootstrap'
        end

        p.options = options

        p.before_exec Proc.new { 
          prepare_build_result_directory 
          prepare_default_hooks
        }
      end
    end

    def default_hooks_directory
      "#{Package.build_directory}/tmp/hooks"
    end

    def prepare_build_result_directory
      mkdir_p build_result_directory
      
      Dir.chdir(build_result_directory) do 
        sh "/usr/bin/dpkg-scanpackages . /dev/null > Packages"
      end
    end

    def prepare_default_hooks
      mkdir_p default_hooks_directory

      apt_update_hook_file = "#{default_hooks_directory}/D80apt-get-update"
      unless File.exists?(apt_update_hook_file)    
        File.open(apt_update_hook_file, "w") do |f|
          f.puts "#!/bin/sh"
          f.puts "apt-get update"
        end 

        FileUtils.chmod 0755, apt_update_hook_file
      end
    end

    def to_s(separator = '/')
      "#{distribution}#{separator}#{architecture}"
    end

    def task_name
      to_s '_'
    end

  end
end

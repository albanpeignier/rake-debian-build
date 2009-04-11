module RubyPbuilder
  class PBuilder
    extend BuildDirectoryMethods
    include HelperMethods

    @@default_build_host = nil

    def self.default_build_host=(host)
      @@default_build_host = host
    end

    def initialize
      @options = {}
      @before_exec_callbacks = []

      yield self if block_given?
    end

    def build_host
      @@default_build_host
    end

    def [](option)
      @options[option.to_sym]
    end

    def []=(option, value)
      @options[option.to_sym] = value
    end

    def options=(options)
      @options = @options.update options
    end

    def options_arguments
      @options.collect do |option, argument| 
        command_option = "--#{option}"
        case argument
        when true
          command_option        
        when Array
          argument.collect { |a| "#{command_option} #{a}" }
        else 
          "#{command_option} #{argument}" 
        end
      end.flatten
    end

    def before_exec(proc)
      @before_exec_callbacks << proc
    end

    def exec(command, *arguments)
      @before_exec_callbacks.each { |c| c.call }

      if build_host
        remote_exec command, *arguments
      else
        sudo "pbuilder", command, *(options_arguments + arguments)
      end
    end

    private 

    def remote_exec(command, *arguments)
      local_build_directory = PBuilder.build_directory
      remote_build_directory = "/var/tmp/debian"

      sh "rsync -av --no-owner --no-group --no-perms --cvs-exclude --exclude=Rakefile --delete #{local_build_directory}/ #{build_host}:#{remote_build_directory}/"

      quoted_arguments = (options_arguments + arguments).join(' ').gsub("'","\\\\\"")
      quoted_arguments = quoted_arguments.gsub(local_build_directory, remote_build_directory)

      sh "ssh #{build_host} \"cd #{remote_build_directory}; sudo pbuilder #{command} #{quoted_arguments}\""
      sh "rsync -av --no-owner --no-group --no-perms #{build_host}:#{remote_build_directory}/ #{local_build_directory}"
    end

  end
end

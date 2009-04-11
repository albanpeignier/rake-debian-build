module Debian::Build
  class ModulePackage < AbstractPackage

    def module_name
      package.gsub(/-module$/,'')
    end

    def define
      namespace @name do
        namespace :pbuild do
          Platform.each do |platform|
            desc "Pbuild #{platform} binary package for #{package}"
            task platform.task_name do |t, args|
              cp "execute-module-assistant", "#{AbstractPackage.build_directory}/tmp"

              pbuilder_options = {
                :logfile => "#{platform.build_result_directory}/pbuilder-#{package}.log"
              }

              platform.pbuilder(pbuilder_options).exec :execute, "-- #{AbstractPackage.build_directory}/tmp/execute-module-assistant #{module_name} #{platform.architecture} #{platform.build_result_directory}"
            end
          end

          desc "Pbuild binary package for #{package} (on #{default_platforms.join(', ')})"
          task :all => default_platforms.collect { |platform| platform.task_name }

        end

        desc "Upload packages for #{package}"
        task "upload" do
          Platform.each do |platform|
            Uploader.rsync Dir["#{platform.build_result_directory}/#{package}-*.deb"], platform.distribution
          end
        end

        # TODO : remove this mock
        namespace :source do 
          task :all 
        end

      end
    end

  end
end

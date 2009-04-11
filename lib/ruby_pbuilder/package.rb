module RubyPbuilder
  class Package < AbstractPackage

    attr_reader :name
    attr_accessor :package, :version, :signing_key, :debian_increment, :exclude_from_build

    def init
      @debian_increment = 1
      # TODO use a class attribute
      @signing_key = ENV['KEY']
    end

    def define
      raise "Version must be set" if version.nil?

      namespace @name do
        namespace "source" do
          desc "Create source directory for #{package} #{version}"
          task "tarball" do
            mkdir_p sources_directory
            Dir.chdir(sources_directory) do
              get source_tarball_url
            end
          end

          desc "Retrieve source tarball for #{package} #{version}"
          task "directory" => "tarball" do
            Dir.chdir(sources_directory) do
              uncompress source_tarball_name

              if source_tarball_name.match /bz2$/ 
                sh "bunzip2 -c #{source_tarball_name} | gzip -c > #{orig_source_tarball_name}" unless File.exists?(orig_source_tarball_name)
              else
                sh "ln -fs #{source_tarball_name} #{orig_source_tarball_name}"
              end
            end

            copy_debian_files
          end

          Distribution.each do |distribution|
            desc "Build source package for #{package} #{version} on #{distribution}"
            task distribution.task_name => :directory do
              copy_debian_files

              dch_options="--preserve --force-distribution"
              Dir.chdir(source_directory) do  
                unless distribution.ubuntu?
                  if distribution.unstable?
                    sh "dch #{dch_options} --release ''"              
                  else
                    sh "dch #{dch_options} --local #{distribution.local_name} --distribution #{distribution} 'Release from unstable'"              
                  end
                else
                  if distribution.unstable?
                    sh "dch #{dch_options} --local ubuntu --distribution #{distribution} 'Release from debian/unstable'"
                  else
                    sh "dch #{dch_options} --local #{distribution.local_name} --distribution #{distribution} 'Release from unstable'"              
                  end
                end

                dpkg_buildpackage_options = []

                if signing_key
                  dpkg_buildpackage_options << "-k#{signing_key}"
                else
                  dpkg_buildpackage_options << "-us -uc"
                end

                if ENV['ORIGINAL_SOURCE']
                  dpkg_buildpackage_options << "-sa"
                end

                sh "dpkg-buildpackage -rfakeroot #{dpkg_buildpackage_options.join(' ')} -S"
              end
            end
          end
          
          desc "Build source packages for #{package} #{version}"
          task :all => Distribution.all.collect { |distribution| distribution.task_name }
        end

        namespace :pbuild do
          Platform.each do |platform|
            desc "Pbuild #{platform} binary package for #{package} #{version}"
            task platform.task_name do |t, args|
              pbuilder_options = {
                :logfile => "#{platform.build_result_directory}/pbuilder-#{package}-#{debian_version}.log"
              }
              platform.pbuilder(pbuilder_options).exec :build, dsc_file(platform)
            end
          end

          desc "Pbuild binary package for #{package} #{version} (on #{default_platforms.join(', ')})"
          task :all => default_platforms.collect { |platform| platform.task_name }

        end

        desc "Upload packages for #{package} #{version}"
        task "upload" do
          changes_files = Dir.glob("#{sources_directory}/#{package}_#{debian_version}*_source.changes")

          Platform.each do |platform|
            platform_changes_files = Dir.glob("#{platform.build_result_directory}/#{package}_#{debian_version}*_#{platform.architecture}.changes")

            unless platform_changes_files.empty?
              # deb packages for architect all shouldn't be uploaded twice
              sh "sed -i '/_all.deb/ d' #{platform_changes_files.join(' ')}" if platform.architecture != 'i386'

              changes_files << platform_changes_files
            end
          end

          changes_files.flatten!

          sh "dupload -t tryphon #{changes_files.join(' ')}"
        end

        desc "Clean files created for #{package} #{version}"
        task "clean" do
          Platform.each do |platform|
            rm_f package_files(platform.build_result_directory)
          end

          rm_f package_source_files

          rm_f "#{sources_directory}/#{source_tarball_name}"
          rm_f "#{sources_directory}/#{orig_source_tarball_name}"
          rm_rf "#{source_directory}"
        end
      end
    end

    def dsc_file(platform)
      suffix = 
        if local_name = platform.local_name
          "#{local_name}1"
        else
          ""
        end
      File.expand_path "#{Package.build_directory}/sources/#{package}_#{debian_version}#{suffix}.dsc"
    end

    def copy_debian_files
      rm_rf "#{source_directory}/debian"
      cp_r "#{package}/debian", "#{source_directory}/debian"
    end

    def sources_directory
      "#{Package.build_directory}/sources"
    end

    def source_tarball_url
      remote_directory = 
        unless package == :hpklinux 
          package.to_s
        else
          "audioscience" 
        end

      "http://www.rivendellaudio.org/ftpdocs/#{remote_directory}/#{source_tarball_name}"
    end

    def source_tarball_name
      case package
      when :rivendell
        "rivendell-#{version}.tar.gz"
      when :hpklinux 
        "hpklinux-#{version}.tar.bz2"
      when :gpio
        "gpio-#{version}.tar.gz"
      end
    end

    def orig_source_tarball_name
      "#{package}_#{version}.orig.tar.gz"
    end

    def source_directory
      "#{sources_directory}/#{name}-#{version}"
    end

    def debian_version
      "#{version}-#{debian_increment}"    
    end

    def package_files(directory = '.')
      fileparts = [ name.to_s ]
      case name
      when :hpklinux
        fileparts << 'libhpi'
      when :rivendell
        fileparts << 'librivendell'
      end

      fileparts.inject([]) do |files, filepart|
        files + Dir.glob("#{directory}/#{filepart}*#{debian_version}*")
      end
    end

    def package_source_files
      %w{.dsc .tar.gz _source.changes}.collect do |extension|
        "#{sources_directory}/#{package}_#{debian_version}#{extension}"
      end
    end

    def package_deb_files(directory = '.')
      package_files(directory).find_all { |f| f.match /\.deb$/ }
    end

  end
end

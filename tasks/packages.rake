namespace "packages" do
  desc "Create packages source for all packages"

  desc "Build source packages for #{Debian::Build.packages.join(' ')}"
  task :sources

  desc "Build binary packages for #{Debian::Build.packages.join(' ')}"
  task :binaries

  desc "Upload packages for #{Debian::Build.packages.join(' ')}"
  task :upload

  Debian::Build.packages.each do |package|
    task :sources => "package:#{package}:source:all"
    task :binaries => "package:#{package}:pbuild:all"
    task :clean => "package:#{package}:clean"
  end

  task :upload do
    Debian::Build::Uploader.default.lock do
      Debian::Build.packages.each do |package|
        Rake::Task["package:#{package}:upload"].invoke
      end
    end
  end
  
end

task :packages => [ "packages:sources", "packages:binaries", "packages:upload" ]

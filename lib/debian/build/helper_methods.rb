module Debian::Build
  module HelperMethods

    def sudo(*args)
      sh (["sudo"] + args).join(' ')
    end

    def uncompress(archive)
      case archive
      when /\.tar\.bz2$/
        sh "tar -xjf #{archive}"
      when /\.tar\.gz$/
        sh "tar -xzf #{archive}"
      when /\.zip$/
        sh "unzip -o -qq #{archive}"
      else
        raise "Unsupported archive type: #{archive}"
      end
    end

    def get(url)
      sh "wget -m --no-directories #{url}"  
    end

  end
end

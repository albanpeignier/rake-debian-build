module Debian::Build
  module HelperMethods

    def sudo(*args)
      sh (["sudo"] + args).join(' ')
    end

    def uncompress(archive)
      options = 
        case archive
        when /bz2$/
          "-j"
        when /gz/
          "-z"
        end

      sh "tar -xf #{archive} #{options}"
    end

    def get(url)
      sh "wget -m --no-directories #{url}"  
    end

  end
end

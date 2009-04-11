module Debian
  module Build
  end
end

require "debian/build/build_directory_methods"
require "debian/build/helper_methods"

require "debian/build/distribution"
require "debian/build/platform"

require "debian/build/pbuilder"

require "debian/build/source_providers"

require "debian/build/abstract_package"
require "debian/build/package"
require "debian/build/module_package"


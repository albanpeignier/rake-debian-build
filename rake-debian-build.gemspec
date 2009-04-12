# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rake-debian-build}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alban Peignier"]
  s.date = %q{2009-04-12}
  s.email = ["alban.peignier@free.fr"]
  s.extra_rdoc_files = ["Manifest.txt"]
  s.files = ["Manifest.txt", "README.rdoc", "Rakefile", "lib/debian/build.rb", "lib/debian/build/abstract_package.rb", "lib/debian/build/build_directory_methods.rb", "lib/debian/build/config.rb", "lib/debian/build/distribution.rb", "lib/debian/build/helper_methods.rb", "lib/debian/build/module_package.rb", "lib/debian/build/package.rb", "lib/debian/build/pbuilder.rb", "lib/debian/build/platform.rb", "lib/debian/build/source_providers.rb", "lib/debian/build/tasks.rb", "lib/debian/build/uploader.rb", "lib/ruby_pbuilder.rb", "rake-debian-build.gemspec", "rivendell-passenger.changes", "spec/debian/build/source_providers_spec.rb", "spec/debian/build/uploader_spec.rb", "spec/spec_helper.rb", "tasks/packages.rake", "tasks/pbuilder.rake", "tasks/setup.rake"]
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rake-debian-build}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rake tasks to build debian packages}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.12.1"])
    else
      s.add_dependency(%q<hoe>, [">= 1.12.1"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.12.1"])
  end
end

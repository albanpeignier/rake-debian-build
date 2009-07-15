%w[rubygems hoe].each { |f| require f }

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('rake-debian-build', '1.0.5') do |p|
  p.developer("Alban Peignier", "alban.peignier@free.fr")
  p.summary = "Rake tasks to build debian packages"
  p.url = "http://github.com/albanpeignier/rake-debian-build"

  p.rubyforge_name       = p.name # TODO this is default value

  p.clean_globs |= %w[**/.DS_Store *~]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

desc 'Recreate Manifest.txt to include ALL files'
task :manifest do
  `rake check_manifest | patch -p0 > Manifest.txt`
end

desc "Generate a #{$hoe.name}.gemspec file"
task :gemspec do
  File.open("#{$hoe.name}.gemspec", "w") do |file|
    file.puts $hoe.spec.to_ruby
  end
end

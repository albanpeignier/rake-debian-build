task :setup => "pbuilder:setup" do
  sudo "apt-get install devscripts"
end

namespace :setup do

  task :ubuntu do
    get 'http://fr.archive.ubuntu.com/ubuntu/pool/main/u/ubuntu-keyring/ubuntu-keyring_2008.03.04_all.deb'
    sudo "dpkg -i ubuntu-keyring_2008.03.04_all.deb"
  end

end

task "clean" => "packages:clean" do
  rm_rf "build"
end

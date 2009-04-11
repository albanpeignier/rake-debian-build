namespace :pbuilder do
  include Debian::Build::HelperMethods

  desc "Install pbuilder"
  task :setup do 
    sudo "apt-get install pbuilder"
  end

  namespace "create" do
    Debian::Build::Platform.each do |platform| 
      desc "Create pbuilder base image for #{platform}"
      task platform.task_name do
        platform.pbuilder.exec :create unless platform.pbuilder_enabled?
      end
    end
  end
  task :create => Platform.all.collect { |platform| "create:#{platform.task_name}" }

  desc "Update pbuilder"
  task :update do
    Debian::Build::Platform.each do |platform| 
      platform.pbuilder.exec :update
    end
  end

  desc "Update pbuilder by overriding config"
  task :update_config do
    Debian::Build::Platform.each do |platform| 
      platform.pbuilder("override-config" => true).exec :update  
    end
  end

end

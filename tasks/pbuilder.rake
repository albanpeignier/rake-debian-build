namespace :pbuilder do
  include RubyPbuilder::HelperMethods

  desc "Install pbuilder"
  task :setup do 
    sudo "apt-get install pbuilder"
  end

  namespace "create" do
    RubyPbuilder::Platform.each do |platform| 
      desc "Create pbuilder base image for #{platform}"
      task platform.task_name do
        platform.pbuilder.exec :create
      end
    end
  end

  desc "Update pbuilder"
  task :update do
    RubyPbuilder::Platform.each do |platform| 
      platform.pbuilder.exec :update
    end
  end

  desc "Update pbuilder by overriding config"
  task :update_config do
    RubyPbuilder::Platform.each do |platform| 
      platform.pbuilder("override-config" => true).exec :update  
    end
  end

end

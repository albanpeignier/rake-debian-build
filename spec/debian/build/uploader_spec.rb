require File.join(File.dirname(__FILE__), '../../spec_helper')

describe Uploader do

  it "should have a Uploader instance in Uploader.default" do
    Uploader.default.should be_instance_of Uploader
  end

  before(:each) do
    @uploader = Uploader.new

    @files = Array.new(3) { |i| "file_#{i}" }
  end

  it "should have a default incoming '/var/lib/debarchiver/incoming'" do
    @uploader.incoming.should == '/var/lib/debarchiver/incoming'
  end

  it "should have a lock file debarchiver.lock in incoming" do
    @uploader.incoming = "path/to/incoming"
    @uploader.lock_file.should == "path/to/incoming/debarchiver.lock"
  end

  describe "dupload" do
    
    it "should run dupload with specified changes files" do
      @uploader.should_receive(:sh).with("dupload", *@files)
      @uploader.dupload(@files)
    end

  end

  describe "lock file" do
    
    it "should be debarchiver.lock in incoming directory" do
      @uploader.incoming = "path/to/incoming"
      @uploader.lock_file.should == "path/to/incoming/debarchiver.lock"
    end

  end

  describe "lock" do

    before(:each) do
      @uploader.stub!(:sh)

      @uploader.host = "host"
      @uploader.stub!(:lock_file).and_return("lock")
    end
    
    it "should raise an error when no host is defined" do
      @uploader.host = nil
      lambda { @uploader.lock { } }.should raise_error
    end

    it "should create a lock file in ssh" do
      @uploader.should_receive(:sh).with("ssh host touch lock")
      @uploader.lock { }
    end

    it "should remove the lock file in ssh" do
      @uploader.should_receive(:sh).with("ssh host rm -f lock")
      @uploader.lock { }
    end

  end

  describe "rsync" do

    before(:each) do
      @uploader.host = "host"
      @uploader.incoming = "/path/to/incoming"
    end
    
    it "should rsync givenl files to incoming target directory" do
      @uploader.should_receive(:sh).with("rsync -av #{@files.join(' ')} host:/path/to/incoming/target")
      @uploader.rsync("target",@files)
    end

  end

end

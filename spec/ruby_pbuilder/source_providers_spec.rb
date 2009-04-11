require File.join(File.dirname(__FILE__), '..', 'spec_helper')


describe TarballSourceProvider do

  before(:each) do
    @package = Package.new(:test) do |p|
      p.version = "1.0"
    end
    @url = 'dummy'
    @provider = TarballSourceProvider.new(@url)
    
    @retriever = TarballSourceProvider::PackageRetriever.new @url, @package
  end

  it "should create a PackageRetriever with url and package" do
    @retriever.stub!(:retrieve)

    TarballSourceProvider::PackageRetriever.should_receive(:new).with(@url, @package).and_return(@retriever)
    @provider.retrieve(@package)
  end

  it "should retrieve with created PackageRetriever" do
    TarballSourceProvider::PackageRetriever.stub!(:new).and_return(@retriever)
    @retriever.should_receive(:retrieve)
    @provider.retrieve(@package)
  end

  describe TarballSourceProvider::PackageRetriever do

    describe "tarball_url" do

      def retriever(url)
        TarballSourceProvider::PackageRetriever.new url, @package
      end

      it 'should replace #{...} with package attributes' do
        retriever('#{name}').tarball_url.should == @package.name.to_s
      end

    end

    describe "tarball_name" do

      it "should be filename in tarball_url" do
        @retriever.stub!(:tarball_url).and_return("http://test/path/to/expected_tarball_name")
        @retriever.tarball_name.should == "expected_tarball_name"
      end

    end

    describe "prepare_orig_tarball" do
      
      it "should create a link to tarball_name with orig_tarball_name when tarball isn't a bzip file" do
        @retriever.stub!(:tarball_name).and_return("tarball.gz")
        @retriever.stub!(:orig_tarball_name).and_return("orig_tarball.gz")

        @retriever.should_receive(:sh).with("ln -fs tarball.gz orig_tarball.gz")
        @retriever.prepare_orig_tarball
      end

      it "should create a gzip tarball from a bzip tarball" do
        @retriever.stub!(:tarball_name).and_return("tarball.bz2")

        @retriever.stub!(:orig_tarball_name).and_return("orig_tarball.gz")
        File.stub!(:exists?).and_return(false)

        @retriever.should_receive(:sh).with("bunzip2 -c tarball.bz2 | gzip -c > orig_tarball.gz")
        @retriever.prepare_orig_tarball
      end
      
    end

  end
  
end

describe AptSourceProvider do
  
  before(:each) do
    @provider = AptSourceProvider.new
    @package = Package.new(:test) do |p|
      p.version = "1.0"
    end
  end

  it "should run apt-get source" do
    @provider.should_receive(:sh).with("apt-get source test")
    @provider.retrieve(@package)
  end

end

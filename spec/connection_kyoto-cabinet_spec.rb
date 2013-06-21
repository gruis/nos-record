require "spec_helper"

describe "NosRecord::Connection::KyotoCabinet" do
  let(:path) do
    File.expand_path("../tmp/spec.kch", __FILE__)
  end
  after(:all) do
    FileUtils.rm_rf path
  end
  context "#new" do
    let(:connection) do
      NosRecord::Connection::KyotoCabinet.new(path)
    end
    it_behaves_like "a connection"
  end
end

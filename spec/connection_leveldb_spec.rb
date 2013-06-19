require "spec_helper"

describe "GemVault::Model::Connection::LevelDB" do
  let(:path) do
    File.expand_path("../tmp/spec.ldb", __FILE__)
  end

  context "#new" do
    let(:connection) do
      GemVault::Model::Connection::LevelDB.new(path)
    end
    it_behaves_like "a connection"
  end
end

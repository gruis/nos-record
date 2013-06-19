require "spec_helper"

describe "GemVault::Model::Connection::LevelDB" do
  let(:path) { ":memory:" }

  context "#new" do
    let(:connection) do
      GemVault::Model::Connection::Sqlite.new(path)
    end
    it_behaves_like "a connection"
  end
end

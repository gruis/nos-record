require "spec_helper"

describe "NosRecord::Connection::LevelDB" do
  let(:path) { ":memory:" }

  context "#new" do
    let(:connection) do
      NosRecord::Connection::Sqlite.new(path)
    end
    it_behaves_like "a connection"
  end
end

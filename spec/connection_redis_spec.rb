require "spec_helper"

describe "GemVault::Model::Connection::Redis" do
  context "#new" do
    let(:connection) do
      GemVault::Model::Connection::Redis.new
    end
    it_behaves_like "a connection"
  end
end

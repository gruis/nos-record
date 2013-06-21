require "spec_helper"

describe "NosRecord::Connection::Redis" do
  context "#new" do
    let(:connection) do
      NosRecord::Connection::Redis.new
    end
    it_behaves_like "a connection"
  end
end

require "spec_helper"
require "gem-vault/server/user"

describe "GemVault::Server::User" do
  let(:model_class) { GemVault::Server::User }
  it_behaves_like "a model class"
  context "#new" do
    let(:model) { GemVault::Server::User.new }
    it_behaves_like "a model instance"
  end
end

require "spec_helper"

module NosRecord
  module Test
    class User
      include Model
      attr_accessor :id
      attr_accessor :email
    end
  end
end

describe "Model" do
  let(:model_class) { NosRecord::Test::User }
  it_behaves_like "a model class"
  context "#new" do
    let(:model) { NosRecord::Test::User.new }
    it_behaves_like "a model instance"
  end
end

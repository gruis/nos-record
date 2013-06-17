#!/usr/bin/env ruby

require "benchmark"
require "bundler"
Bundler.setup
require "gem-vault/server/user"

con  = GemVault::Model::Connection.new
user = GemVault::Server::User.new(:id => "benchmark", :email => "benchmark@gemvau.lt")
n    = 50_000

user.save(con)

Benchmark.bm(15) do |x|
  x.report("read:") do
    n.times { con.get("benchmark") }
  end

  x.report("write:") do
    n.times { user.save(con) }
  end

  x.report("read & write:") do
    n.times do |i|
      con.get("benchmark")
      user.save(con) if n % 10
    end
  end
end

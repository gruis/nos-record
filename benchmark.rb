#!/usr/bin/env ruby

require "benchmark"
require "bundler"
Bundler.setup
require "gem-vault/server/user"
require "gem-vault/model/connection/sqlite"
require "gem-vault/model/connection/redis"

leveldb = GemVault::Model::Connection.new
sqlite  = GemVault::Model::Connection::Sqlite.new
redis   = GemVault::Model::Connection::Redis.new
user    = GemVault::Server::User.new(:id => "benchmark", :email => "benchmark@gemvau.lt")
n       = 5_000
n_human = "#{n / 1000}k"

[["leveldb", leveldb], ["sqlite", sqlite], ["redis", redis]].each do |name, con|
  $stderr.puts "\n\n#{name}"
  key = con.save(user)

  unless con.get(key).is_a?(GemVault::Server::User)
    raise "Failed to retrieve user with #{key.inspect} key"
  end

  Benchmark.bm(20) do |x|
    x.report("(#{n_human}) read:") do
      n.times { con.get(key) }
    end

    x.report("(#{n_human}) write:") do
      n.times { con.save(user) }
    end

    x.report("(#{n_human}) read & write:") do
      n.times do |i|
        con.get(key)
        con.save(user) if n % 10
      end
    end
  end
end

=begin
leveldb
                           user     system      total        real
(5k) read:             0.030000   0.000000   0.030000 (  0.017124)
(5k) write:            0.110000   0.010000   0.120000 (  0.112670)
(5k) read & write:     0.110000   0.000000   0.110000 (  0.116950)


sqlite
                           user     system      total        real
(5k) read:             0.260000   0.090000   0.350000 (  0.337466)
(5k) write:            1.140000   3.030000   4.170000 (  7.401213)
(5k) read & write:     1.420000   3.150000   4.570000 (  7.771793)


redis
                           user     system      total        real
(5k) read:             0.410000   0.080000   0.490000 (  0.506921)
(5k) write:            0.390000   0.080000   0.470000 (  0.486716)
(5k) read & write:     0.810000   0.170000   0.980000 (  1.005607)
=end

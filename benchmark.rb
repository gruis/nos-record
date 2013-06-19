#!/usr/bin/env ruby

require "benchmark"
require "bundler"
Bundler.setup
require "gem-vault/server/user"
require "gem-vault/model/connection"

leveldb    = GemVault::Model::Connection::LevelDB.new
sqlite     = GemVault::Model::Connection::Sqlite.new
redis      = GemVault::Model::Connection::Redis.new
redisock   = GemVault::Model::Connection::Redis.new(:path => "/tmp/redis.sock")
kcb        = GemVault::Model::Connection::KyotoCabinet.new
user       = GemVault::Server::User.new(:id => "benchmark", :email => "benchmark@gemvau.lt")

n       = 5_000
n_human = "#{n / 1000}k"

to_test = [
  ["KyotoCabinet", kcb],
  ["LevelDB", leveldb],
  ["Redis", redis],
  ["Redis (Unix Socket)", redis],
  ["SQLite", sqlite]
]


def report_per_sec(tms, n, space)
  per_sec = tms.real < 1 ? ((1/tms.real) * n) : n / tms.real
  puts "#{space} #{per_sec.round.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")}/sec"
end

to_test.each do |name, con|
  $stderr.puts "\n\n#{name}"
  con.save(user)
  key = user.id

  unless con.get(key, GemVault::Server::User).is_a?(GemVault::Server::User)
    raise "Failed to retrieve user with #{key.inspect} key"
  end

  r_time  = nil
  w_time  = nil
  rw_time = nil

  Benchmark.bm(20) do |x|
    r_time = x.report("(#{n_human}) read:") do
      n.times { con.get(key, GemVault::Server::User) }
    end
    report_per_sec(r_time, n, ("    "))

    w_time = x.report("(#{n_human}) write:") do
      n.times { con.save(user) }
    end
    report_per_sec(w_time, n, ("    "))

    rw_time = x.report("(#{n_human}) read & write:") do
      n.times do |i|
        con.get(key, GemVault::Server::User)
        con.save(user) if n % 10
      end
    end
    report_per_sec(rw_time, n, ("    "))
  end
end

=begin

KyotoCabinet
                           user     system      total        real
(5k) read:             0.030000   0.000000   0.030000 (  0.033991)
     147,097/sec
(5k) write:            0.050000   0.000000   0.050000 (  0.055352)
     90,331/sec
(5k) read & write:     0.070000   0.010000   0.080000 (  0.072730)
     68,748/sec


LevelDB
                           user     system      total        real
(5k) read:             0.030000   0.000000   0.030000 (  0.032942)
     151,782/sec
(5k) write:            0.050000   0.000000   0.050000 (  0.057885)
     86,378/sec
(5k) read & write:     0.090000   0.000000   0.090000 (  0.086949)
     57,505/sec


Redis
                           user     system      total        real
(5k) read:             0.420000   0.100000   0.520000 (  0.536349)
     9,322/sec
(5k) write:            0.390000   0.080000   0.470000 (  0.500218)
     9,996/sec
(5k) read & write:     0.800000   0.170000   0.970000 (  1.005320)
     4,974/sec


Redis (Unix Socket)
                           user     system      total        real
(5k) read:             0.410000   0.090000   0.500000 (  0.509919)
     9,805/sec
(5k) write:            0.400000   0.080000   0.480000 (  0.495219)
     10,097/sec
(5k) read & write:     0.810000   0.160000   0.970000 (  1.009409)
     4,953/sec


SQLite
                           user     system      total        real
(5k) read:             0.220000   0.080000   0.300000 (  0.300650)
     16,631/sec
(5k) write:            0.470000   1.520000   1.990000 (  3.549052)
     1,409/sec
(5k) read & write:     0.790000   1.600000   2.390000 (  3.976819)
     1,257/sec
=end

#!/usr/bin/env ruby

require "benchmark"
require "bundler"
Bundler.setup
require "nos-record"
require "nos-record/client"
require "securerandom"

def report_per_sec(tms, n, space)
  per_sec = tms.real < 1 ? ((1/tms.real) * n) : n / tms.real
  puts "#{space} #{per_sec.round.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")}/sec"
end

class User
  include NosRecord::Model
  attr_accessor :id
  attr_accessor :email
  def initialize(attrs = {})
    attrs.each do |k,v|
      instance_variable_set(:"@#{k}", v)
    end
  end
end

level_path  = File.expand_path("../tmp/bench.ldb", __FILE__)
sqlite_path = File.expand_path("../tmp/bench.sqlite", __FILE__)
kyoto_path  = File.expand_path("../tmp/bench.kch", __FILE__)

begin
  n       = 5_000
  n_human = "#{n / 1000}k"

  user       = User.new(:id => "benchmark", :email => "benchmark@gemvau.lt")
  rand_users = n.times.map { |i| User.new(:id => i.to_s, :email => "bench.#{i}@gemvau.lt") }
  user_ids   = []

  leveldb        = NosRecord::Connection::LevelDB.new(level_path)
  tcp_level      = NosRecord::Client.new("127.0.0.1", 8081)
  sqlite_memory  = NosRecord::Connection::Sqlite.new(":memory:")
  sqlite         = NosRecord::Connection::Sqlite.new(sqlite_path)
  redis          = NosRecord::Connection::Redis.new
  redisock       = NosRecord::Connection::Redis.new(:path => "/tmp/redis.sock")
  kcb            = NosRecord::Connection::KyotoCabinet.new(kyoto_path)
  kt             = NosRecord::Connection::KyotoTycoon.new("http://localhost:1978/")


  to_test = [
    ["KyotoCabinet", kcb],
    ["KyotoTycoon", kt],
    ["LevelDB", leveldb],
    ["Redis", redis],
    ["Redis (Unix Socket)", redis],
    ["LevelDB (TCP Socket)", tcp_level],
    ["SQLite (Memory)", sqlite_memory],
    ["SQLite", sqlite]
  ]

  to_test.each do |name, con|
    $stderr.puts "\n\n#{name}"
    con.save(user)
    key = user.id

    unless con.get(key, User).is_a?(User)
      raise "Failed to retrieve user with #{key.inspect} key"
    end

    r_time  = nil
    w_time  = nil
    rw_time = nil

    Benchmark.bm(20) do |x|
      w_time = x.report("(#{n_human}) write:") do
        n.times do |i|
          user_ids << con.save(rand_users[i])
        end
      end
      report_per_sec(w_time, n, ("    "))

      r_time = x.report("(#{n_human}) read:") do
        n.times do |i|
          con.get(rand_users[i].id, User)
        end
      end
      report_per_sec(r_time, n, ("    "))

      rw_time = x.report("(#{n_human}) read & write:") do
        n.times do |i|
          con.get(rand_users[i].id, User)
          con.save(rand_users[i]) if i % 10
        end
      end
      report_per_sec(rw_time, n, ("    "))
    end
  end

ensure
  [level_path, sqlite_path, kyoto_path].each { |p| FileUtils.rm_rf(p) }
end

=begin
 * 2.6Ghz Intel Core i7
 * 16GB 1600 MHz DDr3
 * APPLE SSD SM512E
 * Ruby 2.0.0p195 (2013-05-14 revision 40734) [x86_64-darwin12.4.0]


KyotoCabinet
                           user     system      total        real
(25k) write:           0.200000   0.010000   0.210000 (  0.204523)
     122,236/sec
(25k) read:            0.220000   0.000000   0.220000 (  0.230515)
     108,453/sec
(25k) read & write:    0.460000   0.010000   0.470000 (  0.461851)
     54,130/sec


LevelDB
                           user     system      total        real
(25k) write:           0.210000   0.010000   0.220000 (  0.216882)
     115,270/sec
(25k) read:            0.230000   0.000000   0.230000 (  0.233257)
     107,178/sec
(25k) read & write:    0.520000   0.010000   0.530000 (  0.504035)
     49,600/sec


Redis
                           user     system      total        real
(25k) write:           1.410000   0.420000   1.830000 (  2.064798)
     12,108/sec
(25k) read:            1.470000   0.430000   1.900000 (  2.070735)
     12,073/sec
(25k) read & write:    2.880000   0.840000   3.720000 (  4.121688)
     6,065/sec


Redis (Unix Socket)
                           user     system      total        real
(25k) write:           1.360000   0.410000   1.770000 (  1.959406)
     12,759/sec
(25k) read:            1.490000   0.390000   1.880000 (  2.126249)
     11,758/sec
(25k) read & write:    2.850000   0.770000   3.620000 (  4.085881)
     6,119/sec


SQLite (Memory)
                           user     system      total        real
(25k) write:           0.970000   0.010000   0.980000 (  0.971103)
     25,744/sec
(25k) read:            0.960000   0.000000   0.960000 (  0.969800)
     25,779/sec
(25k) read & write:    2.090000   0.010000   2.100000 (  2.106009)
     11,871/sec


SQLite
                           user     system      total        real
(25k) write:           2.290000   7.760000  10.050000 ( 17.473671)
     1,431/sec
(25k) read:            1.210000   0.370000   1.580000 (  1.578052)
     15,842/sec
(25k) read & write:    4.020000   8.560000  12.580000 ( 21.033940)
     1,189/sec

---

KyotoCabinet
                           user     system      total        real
(5k) write:            0.030000   0.000000   0.030000 (  0.036349)
     137,555/sec
(5k) read:             0.020000   0.000000   0.020000 (  0.026635)
     187,723/sec
(5k) read & write:     0.050000   0.010000   0.060000 (  0.049049)
     101,939/sec


KyotoTycoon
                           user     system      total        real
(5k) write:            0.170000   0.090000   0.260000 (  0.591140)
     8,458/sec
(5k) read:             0.150000   0.060000   0.210000 (  0.449323)
     11,128/sec
(5k) read & write:     0.300000   0.130000   0.430000 (  0.942016)
     5,308/sec


LevelDB
                           user     system      total        real
(5k) write:            0.030000   0.000000   0.030000 (  0.028667)
     174,417/sec
(5k) read:             0.020000   0.000000   0.020000 (  0.024727)
     202,209/sec
(5k) read & write:     0.060000   0.000000   0.060000 (  0.057370)
     87,154/sec


Redis
                           user     system      total        real
(5k) write:            0.360000   0.070000   0.430000 (  0.440099)
     11,361/sec
(5k) read:             0.370000   0.070000   0.440000 (  0.448924)
     11,138/sec
(5k) read & write:     0.710000   0.130000   0.840000 (  0.854461)
     5,852/sec


Redis (Unix Socket)
                           user     system      total        real
(5k) write:            0.350000   0.070000   0.420000 (  0.422689)
     11,829/sec
(5k) read:             0.370000   0.060000   0.430000 (  0.443687)
     11,269/sec
(5k) read & write:     0.720000   0.140000   0.860000 (  0.866728)
     5,769/sec


LevelDB (TCP Socket)
                           user     system      total        real
(5k) write:            0.070000   0.060000   0.130000 (  0.395606)
     12,639/sec
(5k) read:             0.070000   0.050000   0.120000 (  0.357918)
     13,970/sec
(5k) read & write:     0.160000   0.120000   0.280000 (  0.762992)
     6,553/sec


SQLite (Memory)
                           user     system      total        real
(5k) write:            0.160000   0.000000   0.160000 (  0.164674)
     30,363/sec
(5k) read:             0.200000   0.000000   0.200000 (  0.191918)
     26,053/sec
(5k) read & write:     0.370000   0.000000   0.370000 (  0.376053)
     13,296/sec


SQLite
                           user     system      total        real
(5k) write:            0.410000   1.500000   1.910000 (  3.435052)
     1,456/sec
(5k) read:             0.240000   0.080000   0.320000 (  0.315435)
     15,851/sec
(5k) read & write:     0.730000   1.630000   2.360000 (  4.029274)
     1,241/sec

=end

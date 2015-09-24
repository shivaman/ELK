#!/usr/bin/ruby
 
require 'digest/md5'
require 'time'
#require 'tire'
 
class IPGenerator
  public
  def initialize(session_count, session_length)
    @session_count = session_count
    @session_length = session_length
 
    @sessions = {}
  end
 
  public
  def get_ip
    session_gc
    session_create
 
    ip = @sessions.keys[Kernel.rand(@sessions.length)]
    @sessions[ip] += 1
    return ip
  end
 
  private
  def session_create
    while @sessions.length < @session_count
      @sessions[random_ip] = 0
    end
  end
 
  private
  def session_gc
    @sessions.each do |ip, count|
      @sessions.delete(ip) if count >= @session_length
    end
  end
 
  private
  def random_ip
    octets = []
    octets << Kernel.rand(223) + 1
    3.times { octets << Kernel.rand(255) }
 
    return octets.join(".")
  end
end
 
class LogGenerator
  EXTENSIONS = {
    'html' => 40,
    'php' => 30,
    'png' => 15,
    'gif' => 10,
    'css' => 5,
  }
 
  RESPONSE_CODES = {
    200 => 92,
    404 => 5,
    503 => 3,
  }
 
  USER_AGENTS = {
    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322)" => 30,
    "Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.24 (KHTML, like Gecko) Chrome/11.0.696.50 Safari/534.24" => 30,
    "Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1" => 40,
  }
 
  public
  def initialize(ipgen)
    @ipgen = ipgen
  end
 
  public
  def write_qps(dest, qps, days)
    sleep = 1.0 / qps
    loop do
      write(dest, 1, days)
      sleep(sleep)
    end
  end
 
  public
  def write(dest, count, days)
    count.times do
      ip = @ipgen.get_ip
      ext = pick_weighted_key(EXTENSIONS)
      resp_code = pick_weighted_key(RESPONSE_CODES)
      ua = pick_weighted_key(USER_AGENTS)
      rand = Random.new.rand((-1 * days*86400)..(days*86400))
      date_obj = Time.now.utc + rand
      date = date_obj.strftime("%d/%b/%Y:%H:%M:%S %z")
      index = date_obj.strftime("logstash-%Y.%m.%d")
      filename = "/"+(0...4).map{(69+(rand(3)*3)).chr}.join+"."+ext
      resp_size = resp_code == 200 ? Digest::MD5.hexdigest(filename).gsub(/[a-z]/,"")[0,4].gsub(/^0+/,"").to_i : 0
      memory = ext == 'php' ? resp_size*3 : 0
 
      event = {
        :type       => 'apache',
        :timestamp  => date_obj.utc.iso8601,
        :line       => "#{ip} - - [#{date}] \"GET #{filename} HTTP/1.1\" #{resp_code} #{resp_size} \"-\" \"#{ua}\"",
        :extension  => ext,
        :clientip   => ip,
        :request    => filename,
        :response   => resp_code,
        :bytes      => resp_size,
        :phpmemory  => memory,
        :agent      => ua,
      }
 
=begin
      Tire.index index do
        store event
      end
=end
 
      dest.write("#{event[:line]}\n")
    end
  end
 
  private
  def pick_weighted_key(hash)
    total = 0
    hash.values.each { |t| total += t }
    random = Kernel.rand(total)
 
    running = 0
    hash.each do |key, weight|
      if random >= running and random < (running + weight)
        return key
      end
      running += weight
    end
 
    return hash.keys.first
  end
end
 
$stdout.sync = true
ipgen = IPGenerator.new(100, 10)
LogGenerator.new(ipgen).write_qps($stdout, 50, 0)
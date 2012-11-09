
# encoding: utf-8

# Zabbix sender protocol Version 1.8
# http://www.zabbix.com/wiki/doc/tech/proto/zabbixsenderprotocol

# Implementacje:
# - http://spin.atomicobject.com/2012/10/30/collecting-metrics-from-ruby-processes-using-zabbix-trappers/
# - https://gist.github.com/1170577

require 'socket'
require 'json'

class ZabbixSender18
  def self.send(host, serv = 'localhost', port = 10051, conf = '/etc/zabbix/zabbix_agentd.conf', &blk)
    s = new serv, port, conf
    s.to host, &blk
  end

  def initialize(serv = 'localhost', port = 10051, conf = '/etc/zabbix/zabbix_agentd.conf')
    @serv, @port = serv, port
    load_conf conf
  end

  private_class_method :new

  private

  def to(host, &blk)
    raise ArgumentError, "need block" unless block_given?
    begin
      @keep = true
      @data = {}
      instance_eval &blk
      unless @data.empty?
        connect @data.map { |(key, value)|
          { :host => host.to_s, :key => key.to_s, :value => value.to_s }
        }
      end
    ensure
      @keep = @data = nil
    end
  end

  def send(*args)
    return register args if @keep
    host = args.shift
    key = args.shift
    value = args.shift
    connect :host => host.to_s, :key => key.to_s, :value => value.to_s
  end

  def register(args)
    key = args.shift
    value = args.shift
    @data[key] = value
  end

  def connect(data)
    sock = nil
    begin
      sock = TCPSocket.new @serv, @port
      sock.write rawdata(data)
      parse sock.read
    ensure
      sock.close if sock
    end
  end

  def parse(response)
    JSON.parse response[13 .. -1]
  end

  def rawdata(data)
    data = [data] unless data.instance_of? Array
    baggage = {
      :request => 'sender data',
      :data => data,
    }.to_json
    'ZBXD' + [1, u64le(baggage.bytesize)].flatten.pack("C*") + baggage
  end

  def u64le(integer)
    ary = []
    8.times do |n|
      ary << ((integer >> (n * 8)) & 0xFF)
    end
    ary
  end

  def load_conf(path)
    return unless FileTest.exist? path
    File.open(path, 'rb') do |f|
      f.readlines.each do |line|
        line.gsub!(/#.*$/, '')
        if line =~ /(Server(?:Port)?)\s*=\s*([0-9a-zA-Z\-\_\.]+)\s*/
          key, value = $1, $2
          @serv = value if key == 'Server'
          @port = value if key == 'ServerPort'
        end
      end
    end
  end
end


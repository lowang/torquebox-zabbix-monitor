require 'ostruct'
require 'socket'
require 'base64'

# Note that you MUST disconnect the TCP connection after receiving the response.
# Sending multiple requests over a single connection is not supported
# and you risk tying up resources on the Zabbix server
# if you keep the connection open for too long.
# -- http://www.zabbix.com/wiki/doc/tech/proto/zabbixsenderprotocol
class Zabbixx_Sender
  def initialize(host,port)
    @host = host; @port = port
  end

  def send(zbx_host, zbx_key, item, debug)
    open

    request = "<req>\n<host>"
    request << Base64.encode64(zbx_host.to_s)
    request << "</host>\n<key>"
    request << Base64.encode64(zbx_key.to_s)
    request << "</key>\n<data>"
    request << Base64.encode64(item)
    request << "</data>\n</req>"

    STDOUT.puts "Sending to Zabbix server: \n#{request}" if debug

    @socket.puts request

    result = @socket.gets
    STDOUT.puts "Zabbix server replied: #{result}" if debug

    close

    result == 'OK'
  end

  private

  def open
    @socket = TCPSocket.new(@host, @port)
  end

  def close
    @socket.close
  end
end


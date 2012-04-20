require "ostruct"
require "socket"
require "base64"

class Zabbixx_Sender
  def initialize(host,port)
    @host = host; @port = port
  end

  def open
    @socket = TCPSocket.new(@host, @port)
  end

  def close
    @socket.close
  end

  def send(zbx_host, zbx_key, item, debug)
    open

    request = "<req>\n<host>"
    request << Base64.encode64(zbx_host)
    request << "</host>\n<key>"
    request << Base64.encode64(zbx_key)
    request << "</key>\n<data>"
    request << Base64.encode64(item)
    request << "</data>\n</req>"

    STDOUT.puts "Sending to Zabbix server: \n#{request}" if debug

    @socket.puts request

    result = @socket.gets
    STDOUT.puts "Zabbix server replied: #{result}" if debug

    close

    if result == "OK"
      true
    else
      false
    end
  end
end

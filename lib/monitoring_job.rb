require 'config/environment'

class MonitoringJob

  def initialize(options={})
    @options = options
  end

  def run()
    zabbix = Zabbixx_Sender.new(@options['host'], @options['port'])
    tb_stats = TorqueboxStatsMonitor.new

    [ :get_threads_stats, :get_memory_stats, :get_classes_stats].each do |method|
      begin
        tb_stats.send(method).each do |key,value|
          zabbix.send(hostname, key.to_s, value.to_s, @options['debug'])
        end
      end
    end

    # queues
    begin
      tb_stats.get_queue_stats.each do |queue,stats|
        stats.each do |key,value|
          zabbix.send(hostname, queue.to_s + '.' + key.to_s, value.to_s, @options['debug'])
        end
      end
    end

  end

  private

  def hostname
    Socket.gethostname
  end

end
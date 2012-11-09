require 'config/environment'

class MonitoringJob
  def initialize(options={})
    @options = options
  end

  def run
    zabbix = Zabbixx_Sender.new(@options['host'], @options['port'])
    tb_stats = TorqueboxStatsMonitor.new

    [:get_threads_stats, :get_memory_stats, :get_classes_stats, :get_deployment_descriptors, :get_os_stats].each do |method|
      tb_stats.send(method).each do |key,value|
        zabbix.send(hostname, key.to_s, value.to_s, @options['debug'])
      end
    end

    # queues
    tb_stats.get_queue_stats.each do |queue,stats|
      stats.each do |key,value|
        zabbix.send(hostname, queue.to_s + '.' + key.to_s, value.to_s, @options['debug'])
        zabbix.send(hostname, queue.to_s + '.' + key.to_s + '_rate', value.to_s, @options['debug']) if key.to_s == 'messages_added'
      end
    end
  end

  def self.hostname
    ENV['ZABBIX_STRIP_HOST'] ? Socket.gethostname.gsub(ENV['ZABBIX_STRIP_HOST'], '') : Socket.gethostname
  end

  private

  def hostname
    @hostname ||= self.class.hostname
  end
end


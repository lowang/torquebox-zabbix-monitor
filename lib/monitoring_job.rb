require 'config/environment'

class MonitoringJob
  def initialize(options={})
    @options = options
  end

  def run
    tb_stats = TorqueboxStatsMonitor.new

    response = Zabbix::Sender18.send(hostname, @options['host'], @options['port']) do
      [:get_threads_stats, :get_memory_stats, :get_classes_stats, :get_deployment_descriptors, :get_os_stats].each do |method|
        tb_stats.send(method).each do |key,value|
          send key, value
        end
      end

      tb_stats.get_queue_stats.each do |queue,stats|
        stats.each do |key,value|
          send queue + '.' + key, value
          send queue + '.' + key + '_rate', value if key.to_s == 'messages_added'
        end
      end
    end

    puts response if @options['debug']
  end

  def self.hostname
    ENV['ZABBIX_STRIP_HOST'] ? Socket.gethostname.gsub(ENV['ZABBIX_STRIP_HOST'], '') : Socket.gethostname
  end

  private

  def hostname
    @hostname ||= self.class.hostname
  end
end


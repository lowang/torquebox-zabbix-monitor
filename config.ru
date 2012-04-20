require ::File.expand_path('../config/environment',  __FILE__)

app = lambda do |env|
  json_stats = { 'hostname' => MonitoringJob.hostname }
  tb_stats = TorqueboxStatsMonitor.new
  [ :get_threads_stats, :get_memory_stats, :get_classes_stats].each do |method|
    tb_stats.send(method).each do |key,value|
      json_stats[key.to_s] = value
    end
  end

  # queues
  tb_stats.get_queue_stats.each do |queue,stats|
    stats.each do |key,value|
      json_stats[queue.to_s + '.' + key.to_s] = value
    end
  end
  [200, { 'Content-Type' => 'application/json' }, json_stats.to_json]
end
run app
class TorqueboxStatsMonitor

  def initialize
    @jmx_server = JMX::MBeanServer.new
  end

  def get_queue_stats
    queue_stats = {}
    Backstage::Queue.all.each do |destination|
      qname = ('hornetq.' + destination.name.to_s.gsub(/[^0-9a-zA-Z_\-.]/,'.').gsub('..','.')).to_sym #display_name.gsub(/[^0-9a-zA-Z_\-.]/,'.')
      queue_stats[qname] = {
        message_count:    destination.message_count,
        delivering_count: destination.delivering_count,
        scheduled_count:  destination.scheduled_count,
        messages_added:   destination.messages_added
        #destination.consumer_count
      }
    end
    queue_stats
  end

  # https://github.com/nicksieger/advent-jruby
  def get_memory_stats
    memory = @jmx_server["java.lang:type=Memory"]
    memory_pool = @jmx_server["java.lang:type=MemoryPool,name=PS Perm Gen"]
    { :'torquebox.memory.heap_usage' => memory.heap_memory_usage.used,
      :'torquebox.memory.non_heap_usage' => memory.non_heap_memory_usage.used,
      :'torquebox.memory.perm_gen_usage' => memory_pool.usage.used }
  end

  def get_threads_stats
    threads = @jmx_server["java.lang:type=Threading"]
    { :'torquebox.thread_count' => threads.thread_count,
      :'torquebox.thread_peak_count' => threads.peak_thread_count }
  end

  def get_classes_stats
    classes = @jmx_server["java.lang:type=ClassLoading"]
    { :'torquebox.loaded_class_count' => classes.loaded_class_count }
  end

end
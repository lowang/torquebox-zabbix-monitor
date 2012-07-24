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
      }
    end
    queue_stats
  end

  # https://github.com/nicksieger/advent-jruby
  def get_memory_stats
    memory = @jmx_server["java.lang:type=Memory"]
    memory_pool = @jmx_server["java.lang:type=MemoryPool,name=PS Perm Gen"] rescue nil
    { :'torquebox.memory.heap_usage' => memory.heap_memory_usage.used,
      :'torquebox.memory.non_heap_usage' => memory.non_heap_memory_usage.used,
      :'torquebox.memory.perm_gen_usage' => (memory_pool.usage.used rescue 0) }
  end

  def get_threads_stats
    threads = @jmx_server["java.lang:type=Threading"]
    { :'torquebox.thread.count' => threads.thread_count,
      :'torquebox.thread.peak_count' => threads.peak_thread_count }
  end

  def get_classes_stats
    classes = @jmx_server["java.lang:type=ClassLoading"]
    { :'torquebox.class.loaded_class_count' => classes.loaded_class_count }
  end

  def get_deployment_descriptors
    rt = @jmx_server["java.lang:type=Runtime"]
    jboss_dir = File.dirname(rt.class_path.to_s) # /opt/torquebox/jboss/jboss-modules.jar
    apps = Dir.glob(File.join(jboss_dir, 'standalone', 'deployments', '*'))
    apps_deployed   = apps.select { |file| file =~ /\.deployed/ }.size
    apps_undeployed = apps.select { |file| file =~ /\.undeployed/ }.size
    apps_failed     = apps.select { |file| file =~ /\.failed/ }.size
    { :'torquebox.apps.deployed'   => apps_deployed,
      :'torquebox.apps.undeployed' => apps_undeployed,
      :'torquebox.apps.failed'     => apps_failed
    }
  end

  def get_os_stats
    os = @jmx_server["java.lang:type=OperatingSystem"]
    # process cpu time is ns, so divide by 10**9 to get seconds and divide by 100 to get percentage
    cpu_usage = (cputime = os.process_cpu_time; sleep 1; (os.process_cpu_time - cputime)/(10**9/100))
    { :'torquebox.os.open_file_descriptor_count' => os.open_file_descriptor_count,
      :'torquebox.os.max_file_descriptor_count'  => os.max_file_descriptor_count,
      :'torquebox.os.cpu_usage_percentage'       => cpu_usage
    }
  end

end
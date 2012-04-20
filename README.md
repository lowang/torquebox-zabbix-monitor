torquebox-zabbix-monitor
========================

monitors torquebox instance and pushes notification to zabbix

## Installation

    $ git clone https://github.com/lowang/torquebox-zabbix-monitor.git

Please change config/torquebox.yml to match your zabbix hostname, port and monitoring interval.

Then deploy it as:

    $ torquebox deploy torquebox-zabbix-monitor --env production

## Usage

Deploys to /monitoring context path, serves simple rack controller that present json data that are being monitored.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
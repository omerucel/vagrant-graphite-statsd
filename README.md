Vagrant bash script for statsd & graphite

```bash
$ cd vagrant
$ cp development.rb.sample development.rb
$ cp development.sh.sample development.sh
$ vagrant up
$ vagrant ssh
$ statsd /vagrant/vagrant/files/statsd-config.js
```
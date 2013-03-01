Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

class system-update {

	exec { 'apt-get update':
    	command => 'apt-get update',
  	}

  	$sysPackages = [ "build-essential", "libgearman-dev", "gearman-tools", "poppler-utils" ]
  		package { $sysPackages:
    	ensure => "installed",
    	require => Exec['apt-get update'],
  	}
}

class development {

	$devPackages = [ "curl", "git-core", "php-apc" ]
  	package { $devPackages:
    	ensure => "installed",
    	require => Exec['apt-get update'],
  	}

}

class datacube_php {

    php::module { [
        'curl', 'gd', 'mcrypt', 'memcached', 'mysql',
        'tidy', 'imap', 'intl'
        ]:
        notify => Service['apache'],
    }

    php::module { [ 'memcache' ]:
        notify => Service['apache'],
        source  => '/etc/php5/conf.d/',
    }

    php::module { [ 'xdebug', ]:
        notify  => Service['apache'],
        source  => '/etc/php5/conf.d/',
    }

    exec { 'pecl-mongo-install':
        command => 'pecl install mongo',
        unless => "pecl info mongo",
        notify => Service['apache'],
        require => Package['php-pear'],
    }

    exec { 'pecl-gearman-install':
        command => 'pecl install "channel://pecl.php.net/gearman-1.1.0"',
        unless => 'pecl info "channel://pecl.php.net/gearman-1.1.0"',
        notify => Service['apache'],
        require => Package['php-pear'],
    }

    php::conf { [ 'mysqli', 'pdo', 'pdo_mysql', ]:
        require => Package['php-mysql'],
        notify  => Service['apache'],
    }

  	file { "/etc/apache2/sites-available/default":
      	source  => '/vagrant/conf/apache/sites-available/default',
       	notify => Service['apache'],	
  	}
    
    file { "/etc/php5/conf.d/custom.ini":
        owner  => root,
        group  => root,
        mode   => 664,
        source => "/vagrant/conf/php/custom.ini",
        notify => Service['apache'],
    }    
    
#  	file { "/etc/mysql/my.cnf":
#      mode => 644, owner => root, group => root,
#      source  => '/vagrant/conf/mysql/my.cnf'
#  }    

}

class { "mysql":
  root_password => 'root',          
  source  => '/vagrant/conf/mysql/my.cnf'
}
mysql::grant { 'datacube':
  mysql_privileges => 'ALL',
  mysql_password => 'datacube',
  mysql_db => 'datacube',
  mysql_user => 'datacube',
  mysql_host => '%',
}

user { "datacube":
	ensure => "present",
}
file { '/datacube':
   ensure => 'link',
   target => '/vagrant/project',
}

file { "/var/log/mongo":
    ensure => "directory",
}
file { "/var/lib/mongo":
    ensure => "directory",
}

class { "redis": 
	source  => '/vagrant/conf/redis/redis.conf'
}

class { 'gearman': }

supervisor::service {
  'MitecubeDatacubeBundleWorkerCrawlerManagerWorker':
    ensure      => present,
    enable      => true,
    command     => '/usr/bin/php /vagrant/project/app/console gearman:worker:execute MitecubeDatacubeBundleWorkerCrawlerManagerWorker --no-interaction',
    environment => '',
    numprocs 	=> '2',
    autorestart	=> true,
    user        => 'datacube',
    group       => 'datacube',
    require     => [ Package['gearman-job-server'], User['datacube'] ];

  'MitecubeDatacubeBundleWorkerCrawlerDependentWorker':
    ensure      => present,
    enable      => true,
    command     => '/usr/bin/php /vagrant/project/app/console gearman:worker:execute MitecubeDatacubeBundleWorkerCrawlerDependentWorker --no-interaction',
    environment => '',
    numprocs 	=> '10',
    autorestart	=> true,    
    user        => 'datacube',
    group       => 'datacube',
    require     => [ Package['gearman-job-server'], User['datacube'] ];
    

  'MitecubeDatacubeBundleWorkerManagerWorker':
    ensure      => present,
    enable      => true,
    command     => '/usr/bin/php /vagrant/project/app/console gearman:worker:execute MitecubeDatacubeBundleWorkerManagerWorker --no-interaction',
    environment => '',
    numprocs 	=> '2',
    autorestart	=> true,
    user        => 'datacube',
    group       => 'datacube',
    require     => [ Package['gearman-job-server'], User['datacube'] ];

  'MitecubeDatacubeBundleWorkerEtlCustomCodeWorker':
    ensure      => present,
    enable      => true,
    command     => '/usr/bin/php /vagrant/project/app/console gearman:worker:execute MitecubeDatacubeBundleWorkerEtlCustomCodeWorker --no-interaction',
    environment => '',
    numprocs 	=> '10',
    autorestart	=> true,    
    user        => 'datacube',
    group       => 'datacube',
    require     => [ Package['gearman-job-server'], User['datacube'] ];
    

  'MitecubeQueueBundleWorkerTestWorker':
    ensure      => present,
    enable      => true,
    command     => '/usr/bin/php /vagrant/project/app/console gearman:worker:execute MitecubeQueueBundleWorkerTestWorker --no-interaction',
    environment => '',
    numprocs 	=> '1',
    autorestart	=> true,    
    user        => 'datacube',
    group       => 'datacube',
    require     => [ Package['gearman-job-server'], User['datacube'] ];    
}

class { 'elasticsearch':
  version      => '0.20.4',
  java_package => 'openjdk-7-jre-headless',
  dbdir        => '/var/lib/elasticsearch',
  logdir       => '/var/log/elasticsearch',
}


Exec["apt-get update"] -> Package <| |>

include apt
include system-update
include pear

include php
include php::apache2
include apache
include redis

include datacube_php
include development

include mysql

class {'mongodb':
  enable_10gen => true,
}

include supervisor

#include phpqatools

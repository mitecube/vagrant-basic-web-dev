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

class php_dev {

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
    
}

class { "mysql":
  root_password => 'root',          
  source  => '/vagrant/conf/mysql/my.cnf'
}

#mysql::grant { 'dbname':
#  mysql_privileges => 'ALL',
#  mysql_db => 'dbname',
#  mysql_user => 'dbuser',
#  mysql_password => 'dbpass',
#  mysql_host => '%',
#}


file { "/var/log/mongo":
    ensure => "directory",
}
file { "/var/lib/mongo":
    ensure => "directory",
}

#class { "redis": 
#	source  => '/vagrant/conf/redis/redis.conf'
#}

#class { 'gearman': }


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

include php_dev
include development

include mysql

class {'mongodb':
  enable_10gen => true,
}

#include supervisor

#include phpqatools

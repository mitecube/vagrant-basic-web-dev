vagrant-basic-web-dev
=====================

Description
-----------

Setup a dev environment for Mitecube.

This vagrant configuration sets up a basic LAMP environment suited for Symfony 2 development:

* Based on Ubuntu Lucid
* Apache 2.2
* PHP 5.3 with intl and readline, xdebug, sqlite extensions
* phpMyAdmin
* MySQL Server 5.1
* Git and SVN clients

# Prerequisites

## Install Vagrant

Obviously, you need [Vagrant](http://www.vagrantup.com/), which in turn requires Ruby and VirtualBox. Vagrant runs on Linux, OS X, and Windows, although some special configuration applies to Windows (see below).

## Download and install a base image

	$ vagrant box add vagrant-basic-web-dev http://files.vagrantup.com/precise64.box

This example uses the default Ubuntu image from the Vagrant project, although you can use other Ubuntu boxes if you like. If you do not name the box "base", you will later on need to adapt the Vagrantfile in the project root directory.

## Setup a working directory and start your new environment

    $ git clone https://github.com/mitecube/vagrant-basic-web-dev.git mydir
    $ cd mydir
    $ vagrant up

Depending on the versions of the box and your VirtualBox installation, you might see a notice that the guest additions of the box do not match the version of VirtualBox you are using. If you encounter any problems, you might want to install up to date guest additions on your box once running and [repackage it for use with Vagrant](http://vagrantup.com/docs/getting-started/packaging.html).

If you prefer a clean URL, you might want to map `33.33.33.100` to a local domain of your choice in your hosts file. This is entirely optional.

## Use it

TODO	

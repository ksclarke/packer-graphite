# Packer Graphite [![Build Status](https://travis-ci.org/ksclarke/packer-graphite.png?branch=master)](https://travis-ci.org/ksclarke/packer-graphite)

A Packer.io build for Graphite.  [Packer.io](http://www.packer.io/) is a tool for creating identical machine images for multiple platforms from a single source configuration.  It produces images for Amazon EC2, Digital Ocean, Docker, VirtualBox, VMWare, and others.  [Graphite](https://graphite.readthedocs.org/en/latest/) is an enterprise-scale monitoring (and graphing) tool that runs well on cheap hardware.

## Introduction

Usually a [Packer.io build](http://www.packer.io/docs/command-line/build.html) would be run with something like:

    packer build -only=amazon-ebs -var-file=vars.json graphite.json

This project, though, provides a simple wrapper script. To use that, run:

    ./build.sh

or

    ./build.sh amazon-ebs

or

    ./build.sh docker

This will include the variables file, generate passwords if needed, and strip the comments out of packer-graphite.json, creating the graphite.json file. Currently, only "amazon-ebs" and "docker" builds are supported. In the future, I expect to add support for VirtualBox (virtualbox-iso), VMWare (vmware-iso), and Digital Ocean.  Running the build script without "amazon-ebs" or "docker" will result in both being built.

If you want to run the build in debug mode, try adding the DEBUG flag to one of the above options:

    DEBUG=true ./build.sh

_Note: To have the build script use the packer-graphite.json file, you'll need to have [strip-json-comments](https://github.com/sindresorhus/strip-json-comments) installed.  If you don't have that installed, the build script will use the pre-generated graphite.json file. Any changes meant to persist between builds should be made to the packer-graphite.json file._

## Configuration

Before you run the build script, though, you'll need to configure a few important variables.  To get you started, the project has an `example-vars.json` file which can be copied to `vars.json` and edited.  The build script will then inject these variables into the build.  There are some variables that are general and some that are specific to a particular builder (which will only need to be supplied if you intend to use that builder).

_Note: When running the build script, any variable in the vars.json file that ends with `_password` will get an automatically generated value. To have the build script regenerate the `_password` values with a new build, delete the `.passwords` file before re-running the build script._

### General Build Variables

<dl>
  <dt>server_admin_email</dt>
  <dd>The email address that should be configured as the Apache admin and as the graphiteAdmin user's email address.</dd>
  <dt>server_host_name</dt>
  <dd>Serves as the mail host; "localhost" is the default setting, but it can be whatever you want (a FQDN if appropriate).</dd>
  <dt>packer_build_name</dt>
  <dd>A name that will distinguish your build products from someone else's. It can be a simple string like "Fedora" or "UCLA".</dd>
  <dt>graphite_admin_password</dt>
  <dd>The password for the graphiteAdmin user. If not supplied, the build.sh script will supply an automatically generated password in the graphite.json file.</dd>
  <dt>graphite_secret_key_password</dt>
  <dd>Not really a password, but a secret key for the Graphite installation. If not supplied, the build.sh script will supply an automatically generated value in the graphite.json file.</dd>
</dl>

### Amazon-EBS Variables

<dl>
  <dt>aws_access_key</dt>
  <dd>A valid AWS_ACCESS_KEY that will be used to interact with Amazon Web Services (AWS).</dd>
  <dt>aws_secret_key</dt>
  <dd>The AWS_SECRET_KEY that corresponds to the supplied AWS_ACCESS_KEY.</dd>
  <dt>aws_security_group_id</dt>
  <dd>A pre-configured AWS Security Group that will allow SSH and HTTP access to the EC2 build.</dd>
  <dt>aws_region</dt>
  <dd>The AWS region to use. For instance: <strong>us-east-1</strong> or <strong>us-west-2</strong>.</dd>
  <dt>aws_instance_type</dt>
  <dd>The AWS instance type to use. For instance: <strong>t2.medium</strong> or <strong>m3.medium</strong>.</dd>
  <dt>aws_virtualization_type</dt>
  <dd>The AWS virtualization type to use. For instance: <strong>hvm</strong> or <strong>pv</strong>.</dd>
  <dt>aws_source_ami</dt>
  <dd>The source AMI to use as a base. Note that the source AMI, virtualization type, and instance type must be <a href="http://aws.amazon.com/amazon-linux-ami/instance-type-matrix/">compatible</a>. The two tested AMIs (from 'us-east-1') are <strong>ami-0870c460</strong> (with 'pv' virtualization) and <strong>ami-0070c468</strong> (with 'hvm' virtualization). If you select another, make sure it's an Ubuntu image (as that's what the Packer.io build expects).</dd>
</dl>

### Docker Variables

<dl>
  <dt>docker_user</dt>
  <dd>A Docker user (preferably a Docker registry user). Though the build is not currently configured to push to a Docker registry (like <a href="https://hub.docker.com/">Docker Hub</a>), this functionality will probably be added in the future.</dd>
</dl>

## Deployment

How you deploy the Graphite server will depend on which builder you've selected. These simple instructions assume you're already familiar with AWS and/or Docker.  For information about how to get started with these resources, consult their online documentation.

### AWS EC2 Instance

To deploy in EC2, you'll need to launch a new instance through the AWS Web Console (selecting an instance type, security group, and key pair in the process). The Packer.io build creates an AMI in your account from which the instance can be launched.

These steps will probably be automated in the future with the assistance of the AWS CLI.

### Docker

To deploy Graphite in a Docker container on your local machine (after installing Docker, of course), you can type:

    docker run -p 127.0.0.1:80:80 -p 127.0.0.1:2003:2003 -t -i $(docker images -q | head -1) /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

This should use the most recent local Docker image (i.e., the one you just created) to spin up a Docker container with ports 80 and 2003 mapped to localhost's 80 and 2003 ports.  Graphite's Web interface listens at port 80 and its Carbon-Cache service listens at port 2003.

If you have something already running at one or both of those ports, you'll want to choose different localhost ports to map.  Perhaps something like:

    docker run -p 127.0.0.1:8000:80 -p 127.0.0.1:8001:2003 -t -i $(docker images -q | head -1) /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

## License

[Apache Software License, version 2.0](LICENSE)

## Contact

If you have questions about [packer-graphite](http://github.com/ksclarke/packer-graphite) feel free to ask them on the FreeLibrary Projects [mailing list](https://groups.google.com/forum/#!forum/freelibrary-projects); or, if you encounter a problem, please feel free to [open an issue](https://github.com/ksclarke/packer-graphite/issues "GitHub Issue Queue") in the project's issue queue.

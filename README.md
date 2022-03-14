# Packer Graphite [![Build Status](https://travis-ci.org/ksclarke/packer-graphite.png?branch=master)](https://travis-ci.org/ksclarke/packer-graphite)

A Packer.io build for Graphite.  [Packer.io](http://www.packer.io/) is a tool for creating identical machine images for multiple platforms from a single source configuration.  It produces images for Amazon EC2, Digital Ocean, Docker, VirtualBox, VMWare, and others.  [Graphite](https://graphite.readthedocs.org/en/latest/) is an enterprise-scale monitoring (and graphing) tool that runs well on cheap hardware.

_**Note:** This repo is archived because it's not something I'm actively updating any more._

## Introduction

Usually a [Packer.io build](http://www.packer.io/docs/command-line/build.html) would be run with something like:

    packer build -only=amazon-ebs -var-file=vars.json graphite.json

This project, though, provides a simple wrapper script. To use that, type:

    ./build.sh

or

    ./build.sh amazon-ebs

or

    ./build.sh docker

or

    ./build.sh digitalocean

You can also use more than one builder by using supplying a comma delimited list. For example, typing the following will produce Docker and Digital Ocean artifacts:

    ./build.sh docker,digitalocean

Using the build script includes the variables file, generates passwords if needed, strips the comments out of `packer-graphite.json` and creates `graphite.json` (which is used as the build file).

Currently, only "amazon-ebs", "docker", and "digitalocean" builds are supported. In the future, I expect to add additional support for VirtualBox (virtualbox-iso) and VMWare (vmware-iso).  Running the build script without "amazon-ebs", "docker" or "digitalocean" will result in all being built.

If you want to run the build in debug mode, try adding the DEBUG flag to one of the above options:

    DEBUG=true ./build.sh

If you've edited the `packer-graphite.json` file and want to validate the build without running it, type:

    ./build.sh validate

_Note: To have the build script use the packer-graphite.json file, you'll need to have [strip-json-comments](https://github.com/sindresorhus/strip-json-comments) installed.  If you don't have that installed, the build script will use the pre-generated graphite.json file. Any changes meant to persist between builds should be made to the packer-graphite.json file. This requirement will be removed when Packer.io switches its configuration file format from JSON to [HCL](https://github.com/hashicorp/hcl)._

## Configuration

Before you run the build script, though, you'll need to configure a few important variables.  To get you started, the project has an `example-vars.json` file which can be copied to `vars.json` and edited.  The build script will then inject these variables into the build.  There are some variables that are general and some that are specific to a particular builder (which will only need to be supplied if you intend to use that builder).

_Note: When running the build script, any empty variable in the vars.json file that ends with `_password` will get an automatically generated value. Once a password has been automatically generated, it will continue to be refreshed with a new password at each build.  To stop this, and keep the passwords currently in the `vars.json` file, delete the `.passwords` file found in the project directory._

### General Build Variables

<dl>

  <dt>server_admin_email</dt>
  <dd>The email address that should be configured as the Apache admin and as the graphiteAdmin user's email address.</dd>

  <dt>server_host_name</dt>
  <dd>The name from which mail is sent; "localhost" is the default setting, but it can be whatever you want (e.g., a FQDN).</dd>

  <dt>packer_build_name</dt>
  <dd>A name that will distinguish your build products from someone else's. It can be a simple string like "Fedora" or "UCLA".</dd>

  <dt>graphite_admin_password</dt>
  <dd>The password for the graphiteAdmin user. If not supplied, the build.sh script will supply an automatically generated password in the graphite.json file.</dd>

  <dt>graphite_secret_key_password</dt>
  <dd>Not really a password, but a secret key for the Graphite installation. If not supplied, the build.sh script will supply an automatically generated value in the graphite.json file.</dd>

</dl>

### Amazon-EBS Specific Variables

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

### Docker Specific Variables

<dl>

  <dt>docker_user</dt>
  <dd>A Docker user (preferably a Docker registry user) used to disambiguate the build. Though the build is not currently configured to push to a Docker registry (like <a href="https://hub.docker.com/">Docker Hub</a>), this functionality will probably be added in the future.</dd>

</dl>

### Digital Ocean Specific Variables

<dl>

  <dt>digitalocean_image</dt>
  <dd>The Digital Ocean source image to use; the default is the last Ubuntu Long Term Support (LTS) release. If you select another, make sure it's an Ubuntu image (as that's what the Packer.io build expects).</dd>

  <dt>digitalocean_api_token</dt>
  <dd>The API v2 <a href="https://cloud.digitalocean.com/settings/applications">Personal Access Token</a> for your Digital Ocean account. Version 1 of the Digital Ocean API uses two tokens, so you'll need to use the later version of the API.</dd>

  <dt>digitalocean_region</dt>
  <dd>The region into which your Digital Ocean Droplet spins up.  These are coordinated with the source image (not all source images are available in all regions), so if you change one be sure to check the other.</dd>

  <dt>digitalocean_size</dt>
  <dd>The amount of RAM to make available to the Droplet.  The default configuration of this project is 1 GB, but other options are available.  Consult the Digital Ocean documentation for more details.</dd>

</dl>

## Deployment

How you deploy the Graphite server will depend on which builder you've selected. These simple instructions assume you're already familiar with AWS and/or Docker.  For information about how to get started with these resources, consult their online documentation.

### AWS EC2 Instance

To deploy in EC2, you'll need to launch a new instance through the AWS Web Console (selecting an instance type, security group, and key pair in the process). The Packer.io build creates an AMI in your account from which the instance can be launched.

These steps will probably be automated in the future with the assistance of the AWS CLI.

### Docker

To deploy Graphite in a Docker container on your local machine (after installing Docker, of course), you can type:

    docker run -p 80:80 -p 2003:2003 -t -i $(docker images -q | head -1) /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

This should use the most recent local Docker image (i.e., the one you just created) to spin up a Docker container with ports 80 and 2003 mapped to localhost's 80 and 2003 ports.  Graphite's Web interface listens at port 80 and its Carbon-Cache service listens at port 2003.

You can alternatively reference it using the tag created from your docker_user, project name, and project version; for instance:

    docker run -p 80:80 -p 2003:2003 -t -i ksclarke/packer-graphite:0.1.0 /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

If you have something already running at one or both of those ports, you'll want to choose different localhost ports to map.  Perhaps something like:

    docker run -p 8000:80 -p 8003:2003 -t -i ksclarke/packer-graphite:0.1.0 /usr/bin/supervisord -c /etc/supervisor/supervisord.conf

If you have Docker [Fig](http://www.fig.sh/) installed, you can take advantage of the project's automatically generated `fig.yml` file and just run:

    fig up

This will start the Graphite container with the pre-configured port mappings.

## Potential Gotchas

* There is an [outstanding issue](https://github.com/mitchellh/packer/issues/1752) with Docker 1.4.x and Packer's shell provisioner (which this project uses).  It works fine with Docker 1.3.3, though, so use that instead of Docker 1.4.x until the issue is resolved.
* The 'amazon-ebs' builder fails occasionally; the failure looks like this [outstanding issue](https://github.com/mitchellh/packer/issues/1539) and also [this related one](https://github.com/mitchellh/packer/pull/1764). Re-running the build 'fixes' it.

## License

[Apache Software License, version 2.0](LICENSE)

## Contact

If you have questions about [packer-graphite](http://github.com/ksclarke/packer-graphite) feel free to ask them on the FreeLibrary Projects [mailing list](https://groups.google.com/forum/#!forum/freelibrary-projects); or, if you encounter a problem, please feel free to [open an issue](https://github.com/ksclarke/packer-graphite/issues "GitHub Issue Queue") in the project's issue queue.

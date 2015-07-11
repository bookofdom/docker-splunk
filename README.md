# Docker image with Splunk Enterprise

> Docker Splunk Enterprise image

## Running

To start Splunk use next command

```
docker run --hostname splunk -p 8000:8000 -d outcoldman/splunk:6.2.4
```

This docker image has two data volumes `/opt/splunk/etc` and `/opt/splunk/var`. Recommended to store them in docker volume containers (see [Managing data in containers](https://docs.docker.com/userguide/dockervolumes/))

```
docker run --name vsplunk -v /opt/splunk/etc -v /opt/splunk/var busybox
docker run --hostname splunk --name splunk --volumes-from=vsplunk -p 8000:8000 -d outcoldman/splunk:6.2.4
```

Or if you use [docker-compose](https://docs.docker.com/compose/)

```
vsplunk:
  image: busybox
  volumes:
    - /opt/splunk/etc
    - /opt/splunk/var

splunk:
  image: outcoldman/splunk:6.2.4
  hostname: splunk
  volumes_from:
    - vsplunk
  ports:
    - 8000:8000
```

## Configurations

### User

Splunk is running under `splunk` user.

### Ports

Three ports are exposed

* `8000` - Splunk Web interface
* `8089` - Splunk Services
* `8191` - Application KV Store

### Volumes

This image has two data volumes

* `/opt/splunk/etc` - stores Splunk configurations, including applications and lookups
* `/opt/splunk/var` - stores indexed data, logs and internal Splunk data

### Entrypoint

You can execute Splunk commands by using

```
docker exec splunk entrypoint.sh splunk version
```

### Hostname

It is recommended to specify `hostname` for this image, so if you will recreate Splunk instance you will be able to easily work with old logs.

docker-reviewboard
==================

Dockerized reviewboard. This container follows Docker's best practices, and DOES NOT include sshd, supervisor, apache2, or any other services except the reviewboard itself which is run with ```uwsgi```.

The requirements are MySQL and memcached. This fork is intended for use AWS RDS MySQL and ElastiCache memcached.

After that, go the url, e.g. ```http://localhost/```, login as ```admin:admin```, change the admin password, and change the location of your SMTP server so that the reviewboard can send emails. You are all set!

For details, read below.

## Dependencies

- MySQL (e.g. AWS RDS)
- Memcached (e.g. AWS ElastiCache)

## Settings

### Volumes

This container has one volume mount-point:

- `/var/www/` - The path where the reviewboard site resides, this includes its ssh keys and uploaded media.
If running in a Kubernetes cluster, make sure you are using a persistent volume, else you will lose your configurations when rebooted.

### Variables

The container accepts the following environment variables:
- ```MYSQL_HOST``` - The endpoint for MySQL. Does not include port. Defaults to localhost.
- ```MYSQL_PORT``` - Port for MySQL. Defaults to 3306.
- ```MYSQL_USER``` - User for MySQL. Defaults to ```reviewboard```.
- ```MYSQL_DB``` - MySQL database. Defaults to ```reviewboard```.
- ```MYSQL_PASSWORD``` - MySQL password. Defaults to ```reviewboard```.
- ```MEMCACHED_ENDPOINT``` - Memcached endpoint without the port. No default value
- ```MEMCACHED_PORT``` - Port for memcached endpoint. Defaults to 11211
- ```DOMAIN``` - Defaults to ```0.0.0.0``` (listen from all).
- ```DEBUG``` - If set, the django server will be launched in debug mode.
- ```SITE_ROOT``` - Path of the site, relative to the domain. This should start and end with a ```/```. For example, ```/reviews/```. Defaults to ```/```.

Also, uwsgi accepts environment prefixed with ```UWSGI_``` for it's configuration
E.g. ```-e UWSGI_PROCESSES=10``` will create 10 reviewboard processes.

### Container SMTP settings

Generate AWS SES credentials and set them through the site administration UI once launched

## Upgrading

Upgrading to a new ReviewBoard version is as simple as pulling and running the latest image (or use a specific tag).
The upgrade will be detected at runtime and `rb-site upgrade` will be executed. See: https://www.reviewboard.org/docs/manual/dev/admin/upgrading/upgrading-sites

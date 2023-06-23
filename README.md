# chirpstack-v3-to-v4-on-k8s

Migrate Chirpstack from v3 to v4 on Kubernetes

## Requirements on controller machine

* Bash
* Make
* Docker Client
* kustomize
* Helm
* kubectl

## Preparations

### Provide the configuration files

1. Place your chirpstack.toml for v4 in `configurations/v4/cs/`.
2. Place your chirpstack-application-server.toml for v3 in `configurations/v3/as/`.
3. Place your chirpstack-network-server.toml for v3 in `configurations/v3/ns/`. You can place more than one configuration for the network-server.

`chirpstack-v3-to-v4` will only use the connection data for Postgres and Redis from the configuration files. Accordingly, at most the following settings are taken from the tomls - see also [https://github.com/chirpstack/chirpstack-v3-to-v4/blob/v4.0.4/main.go#L54](https://github.com/chirpstack/chirpstack-v3-to-v4/blob/v4.0.4/main.go#L54):
* `postgresql.dsn`
* `redis.url`
* `redis.servers`
* `redis.cluster`
* `redis.master_name`
* `redis.password`
* `redis.database`
* `redis.tls_enabled`
* `redis.key_prefix`

Further settings will be ignored and do not need to be provided.
Please also note that no environment variables are used and, for example, passwords must be set directly in the configuration files. For more information, see [https://github.com/chirpstack/chirpstack-v3-to-v4#chirpstack-v3-to-v4-data-migration](https://github.com/chirpstack/chirpstack-v3-to-v4#chirpstack-v3-to-v4-data-migration).

### Edit the Makefile to make use of your container repository

4. Set `IMAGE_TAG_BASE` in the Makefile acc. to your needs. `IMAGE_TAG_BASE` should contain the image path without the image tag.

## Make use of make

* `make docker-build` builds the container image.
* `make docker-push` pushes the container image.
* `make render` renders the manifests.
* `make deploy` deploys the migration.
* `make undeploy` undeploys the migration.
* `make clean` removes generated temporary files and folders.

# docker-registry

### Usage

catalog

```cmd
curl -k https://127.0.0.1:18579/v2/_catalog
```

tags

```cmd
curl -k https://127.0.0.1:18579/v2/{name}/tags/list
```

manifests

```cmd
curl -k https://127.0.0.1:18579/v2/{name}/manifests/{version}
```

digest

```cmd
curl -k -sS -o nul -w "%header{Docker-Content-Digest}" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://127.0.0.1:18579/v2/{name}/manifests/{version}
```

delete

```cmd
curl -k -X DELETE https://127.0.0.1:18579/v2/{name}/manifests/{digest}
```

vacuum

```cmd
for /f %a in ('docker ps -aqf "name=docker-registry"') do (docker container exec -it %a registry garbage-collect -m /etc/docker/registry/config.yml)
```

### Installation

[Docker Hub](https://hub.docker.com/_/registry)

```cmd
copy docker-compose.yaml.registry docker-compose.yaml
```

```cmd
notepad docker-compose.yaml
```

```cmd
docker compose -f docker-compose.yaml up -d
```

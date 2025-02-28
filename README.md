# GitLab

Deploys GitLab with docker compose

## Initial installation

See official documentatation [here](https://docs.gitlab.com/ee/install/docker/installation.html).

Rename `.env-sample` to `.env` and put in your values.

### HTTPS access

I use Traefik as a reverse proxy with a dynamic file provider.

Docker host for GitLab: 10.1.15.12

Traefik config:

```yml
...http routers
    gitlab:
      entryPoints:
        - "https"
      rule: "Host(`gitlab.{{env "PRIVATE_HOSTNAME"}}`)"
      middlewares:
        - private
        - https-redirectscheme
      tls: {}
      service: gitlab  
...http services
    gitlab:
      loadBalancer:
        servers:
          - url: "https://10.1.15.12:443"
        passHostHeader: true
```

### SSH access

SSH cannot use SNI, so I do this:

- The host running the Traefik docker container listens to SSH on port 2222
- The Traefik container has 22 as an entry point
- The host running the GitLab docker container listens to SSH on port 22 (the default)
- The GitLab service definition forwards host port 2222 to container 22

#### Traefik

```yml
    gitlab-ssh:
      entryPoints:
        - "ssh"
      rule: "HostSNI(`gitlab.{{env "PRIVATE_HOSTNAME"}}`)"
      middlewares:
        - tcp-RFC1918-only
      service: "gitlab-ssh"
      tls: true
```

TCP service:

```yml
    gitlab-ssh:
      loadBalancer:
        servers:
          - address: "10.1.15.11:2222"
```

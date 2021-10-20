What will be installed?
- A HTCondor WN configured to register via shared secret to a remote pool
    - it will consists in a single partitionable slot with the whole node resources
- A cvmfs container mounting all the needed repositories
- An auto heal daemon to restart unhealthy containers

```text
                                                          ▲
                                                          │
┌─────────────────────────────────────────┐               │
│                                         │               │ To remote pool
│         HTCondor STARTD                 │               │
│                                         ├───────────────┘
│              Partionable                │   shared secret
├──────────────────────┬─────────┬────────┤
│                      │         │        │
│     SLOT 1           │  SLOT 2 │ SLOT 3 │
│                      │         │        │
├──────────────────────┴─────────┴────────┤
│                                         │
│                CVMFS                    │
│                                         │
└─────────────────────────────────────────┘
```

## Requirements
- [docker](https://docs.docker.com/engine/install/)
    - most commonly you will only need the following:
    ```bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    ```
- [docker-compose](https://docs.docker.com/compose/install/)
    - on linux, usually this is done via:
    ```bash
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    ```

## Preparation

Firs of all create all the needed directories:
```bash
# clone this repository
git clone https://github.com/comp-dev-cms-ita/compose-htc-wn
cd compose-htc-wn
# Here the condor logs will be stored
mkdir ./logs
sudo chown 64:64 -R ./logs
# Here the cvmfs repos will be mounted
mkdir ./cvmfs

# Put in this file the shared secret to authenticate with the remote schedd
echo -n "HTC SHARED SECRET HERE" > ./shared-secret/pool_password
sudo chown root ./shared-secret/pool_password
sudo chmod 600 ./shared-secret/pool_password
```

Finally you will need a few configurations specific for you site. You should do this simply putting in `.env` file the following information:

```text
_condor_SiteName = "\"YOUR SITE NAME HERE\""
NUM_CPUS = 8
MEMORY = 16000
```

> __N.B.__ be careful on leaving the `\"` where they are in the example

## Deploy

Now everything should be ready to go. Bring up the system with:

```bash
docker-compose up -d
```

and monitor the status via a simple `docker ps` command.
When everything is in status `healthy` (that can take several minutes), you should be able to find the logs of the WN on `./logs` folder.

## Using OpenStack?

We have a cloud init file for all the setup above:

```text
#cloud-config
write_files:
- content: |
    #!/bin/bash
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    git clone https://github.com/comp-dev-cms-ita/compose-htc-wn
    cd compose-htc-wn
    # Here the condor logs will be stored
    mkdir ./logs
    sudo chown 64:64 -R ./logs
    # Here the cvmfs repos will be mounted
    mkdir ./cvmfs

    # Put in this file the shared secret to authenticate with the remote schedd
    echo -n "HTC SHARED SECRET HERE" > ./shared-secret/pool_password
    sudo chown root ./shared-secret/pool_password
    sudo chmod 600 ./shared-secret/pool_password

    cat << EOF  > .env
    _condor_SiteName = "\"YOUR SITE NAME HERE\""
    NUM_CPUS = 8
    MEMORY = 16000
    EOF

    docker-compose up -d

  path: /usr/local/bin/wn-install.sh
runcmd:
  - ["/bin/bash", "/usr/local/bin/wn-install.sh"]
```

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
- a valid telegraf token to be able to push metrics to the central InfluxDB
  - please contact diego.ciangottini<at>pg.infn.it to obtain one
  - then insert it in `telegraf-config/telegraf.conf` where you find `token = "CHANGEME" `
- put your site name in place if the tag `SITENAME HERE` in the `telegraf-config/telegraf.conf` file
- allow telegraf to monitor the docker metrics with the following command: `echo "GID=$(stat -c '%g' /var/run/docker.sock)" >> .env`
- ❗At least 20GB per core are required for the host machine. In alternative it is also possible plug in an external volume dedicate to the worker node execute folder.
- ❗At least 4GB reserved for `./cvmfs/cache` area, where cvmfs will cache singularity images

## Preparation

Firs of all create all the needed directories:
```bash
# clone this repository
git clone https://github.com/comp-dev-cms-ita/compose-htc-wn --branch lhcb
cd compose-htc-wn
# Here the condor logs will be stored
mkdir ./logs
sudo chown 64:64 -R ./logs
# Here the cvmfs repos will be mounted and cached
mkdir -p ./cvmfs/cache
sudo chown 102:102 -R ./cvmfs/cache

# CVMFS cache limit to 4GB (adapt it to your space availability)
echo "CVMFS_QUOTA_LIMIT=4000" >> ./default-local/images.dodas.infn.it.conf

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

>  :exclamation: __N.B. Only for setup with external volume for wn spool dir__ 
> 
> Mount on ./wn-spool the external volume and set the correct permission
> ```bash
> sudo mkdir ./wn-spool
> sudo mount /dev/vdb1 ./wn-spool
> sudo chown 64:64 -R ./wn-spool
>```
>
> Then in `docker-compose.yaml` uncomment the following lines (both under WN and telegraf service):
> 
> ```yaml
>   - type: bind
>      source: ./wn-spool
>      target: /var/lib/condor/execute
> ```

Now everything should be ready to go. Bring up the system with:

```bash
docker-compose up -d
```

and monitor the status via a simple `docker ps` command.
When everything is in status `healthy` (that can take several minutes), you should be able to find the logs of the WN on `./logs` folder.

### Reconfigure

If you need to change a configuration parameter, you also need to restart the containers in order to make the change taking effect:

```bash
docker-compose down
docker-compose up -d
```

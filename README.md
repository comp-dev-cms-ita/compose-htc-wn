# compose-htc-wn
Docker compose to setup a functioning WNs attaching to a remote scheduler.

What will be installed?
- A HTCondor WN configured to register via shared secret to a remote pool
    - it will consists in a single partitionable slot with the whole node resources
- A cvmfs container mounting all the needed repositories

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
- docker
- docker-compose

## Preparation

Firs of all create all the needed directories:
```bash
# Here the condor logs will be stored
mkdir ./logs
# Here the cvmfs repos will be mounted
mkdir ./cvmfs

# Put in this file the shared secret to authenticate with the remote schedd
echo "HTC SHARED SECRET HERE" > ./shared-secret/pool_password
```

Finally you will need a few configurations specific for you site. You should do this simply putting in `.env` file the following information:

```text
_condor_SiteName = "YOUR SITE NAME HERE"
NUM_CPUS = 8
MEMORY = 16000
```

## Deploy

Now everything should be ready to go. Bring up the system with:

```bash
docker-compose up -d
```

and monitor the status via a simple `docker ps` command.

When everything is healthy, you should be able to find the logs of the WN on `./logs` folder.
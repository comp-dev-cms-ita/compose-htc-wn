What will be installed?
- A Telegraf container sending metrix to an influxDB server
- An auto heal daemon to restart unhealthy containers

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
  - please contact diego.ciangottini@pg.infn.it or tommaso.tedeschi@pg.infn.it to obtain one
  - then insert it in `telegraf-config/telegraf.conf` where you find `token = "CHANGEME" `
- put your site name in place if the tag `SITENAME HERE` in the `telegraf-config/telegraf.conf` file
- allow telegraf to monitor the docker metrics with the following command: `echo "GID=$(stat -c '%g' /var/run/docker.sock)" >> .env`

## Deploy

Bring up the system with:

```bash
git clone https://github.com/comp-dev-cms-ita/compose-htc-wn.git -b telegraf_AF20
cd compose-htc-wn
docker-compose up -d
```

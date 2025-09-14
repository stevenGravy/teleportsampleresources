
#Teleport proxy to connect to, should includ port
# ex: teleport.example.com:443
TELEPORT_CLUSTER_PROXY ?=

#Version client should be, e.g. 8.3.7 9.0.1....  Should match
# the server version. Confirm version with
# curl https://teleport.example.com/webapi/ping | jq
TELEPORT_VERSION ?=18.2.1

# Token to use for agents. should be app, database and node.  Create with below
# tctl tokens add --type=app,db,node
TELEPORT_TOKEN ?=

# optional parameter such as --insecure when connecting
# to non-signed TLS certs
ADDITIONAL_AGENT_PARAMETERS ?= 

TELEPORT_DOCKER_IMAGE=public.ecr.aws/gravitational/teleport-ent-distroless

export

.PHONY: setup
setup:
	@echo "writing .env file for docker-compose"
	@echo "TELEPORT_PROXY_PROXY=${TELEPORT_CLUSTER_PROXY}" > .env
	@echo "TELEPORT_VERSION=${TELEPORT_VERSION}" >> .env
	@echo "TELEPORT_TOKEN=${TELEPORT_TOKEN}" >> .env
	@echo "TELEPORT_DOCKER_IMAGE=${TELEPORT_DOCKER_IMAGE}" >> .env
	@echo "ADDITIONAL_AGENT_PARAMETERS=${ADDITIONAL_AGENT_PARAMETERS}" >> .env
	@echo "${TELEPORT_TOKEN}" > node/token
	@echo ".env complete"
	@echo "setup ssh nodes"
	@cp ./node/teleport-ssh.yaml ./node/teleport-dev.yaml
	@cp ./node/teleport-ssh.yaml ./node/teleport-prod.yaml
	@cp ./node/teleport-multi.yaml ./node/teleport.yaml
	@sed -i  "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./node/teleport.yaml
	@sed -i  "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./node/teleport-dev.yaml
	@sed -i  "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./node/teleport-prod.yaml
	@sed -i  "s|TELEPORT_ENV|dev|g" ./node/teleport-dev.yaml
	@sed -i  "s|TELEPORT_ENV|prod|g" ./node/teleport-prod.yaml
	@echo "node ssh complete"
	@echo "setup grafana"
	@cp ./grafana/grafana.ini.template ./grafana/grafana.ini
	@echo "setup database certs"
	@sudo chown 999 dbdev/server.key dbprod/server.key
	@sudo chmod +r dbdev/server.c* dbprod/server.c*
	@echo "setup grafana ini with subs"
	@sed -i  "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./grafana/grafana.ini
	@echo "setup complete"
# Comment out this line when on MacOS
# Uncomment this line when on MacOS
# @sed -i "" "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./grafana/grafana.ini

.PHONY: clean-all-data-no-confirm
clean-all-data-no-confirm:
	docker volume rm -f teleportsampleresources_teleportdev
	docker volume rm -f teleportsampleresources_teleportprod
	docker volume rm -f teleportsampleresources_teleport
	docker volume rm -f teleportsampleresources_dbproddata
	docker volume rm -f teleportsampleresources_dbdevdata
	docker volume rm -f teleportsampleresources_grafanadev
	docker volume rm -f teleportsampleresources_grafanaprod 	
	rm -rf ./dbdev/server.*
	rm -rf ./dbprod/server.*
	
.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down


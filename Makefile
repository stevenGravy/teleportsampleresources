
#Teleport proxy to connect to, should includ port
# ex: teleport.example.com:443
TELEPORT_CLUSTER_PROXY ?= 

#Version client should be, e.g. 8.3.7 9.0.1....  Should match
# the server version. Confirm version with
# curl https://teleport.example.com/webapi/ping | jq
TELEPORT_VERSION ?= 9.1.3

# Token to use for agents. should be app, database and node.  Create with below
# tctl tokens add --type=app,db,node
TELEPORT_TOKEN ?= 

# optional parameter such as --insecure when connecting
# to non-signed TLS certs
ADDITIONAL_AGENT_PARAMETERS ?= 

export

.PHONY: setup
setup:
	@chmod +x node/pam/teleport_acct
	@echo "writing .env file for docker-compose"
	@echo "TELEPORT_PROXY_PROXY=${TELEPORT_CLUSTER_PROXY}" > .env
	@echo "TELEPORT_VERSION=${TELEPORT_VERSION}" >> .env
	@echo "TELEPORT_TOKEN=${TELEPORT_TOKEN}" >> .env
	@echo ".env complete"
	@echo "setup grafana"
	@cp ./grafana/grafana.ini.template ./grafana/grafana.ini
	@sed -i  "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./grafana/grafana.ini
# change to this line when on MacOS
#	@sed -i "" "s|TELEPORT_CLUSTER_PROXY|${TELEPORT_CLUSTER_PROXY}|g" ./grafana/grafana.ini

.PHONY: clean-all-data-no-confirm
clean-all-data-no-confirm:
	rm -rf ./node/libs
	mkdir ./node/libs
	rm -rf ./grafana/data
	mkdir ./grafana/data
	rm -rf ./dbdev/data
	mkdir ./dbdev/data
	rm -rf ./dbprod/data
	mkdir ./dbprod/data
	rm -rf ./dbdev/server.*
	rm -rf ./dbprod/server.*
	
.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down


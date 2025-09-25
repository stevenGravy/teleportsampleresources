# Sample Resources

This repository provides how to have sample resources for a Teleport Cluster Proxy including
  - SSH Nodes
  - Web App
  - PostgreSQL DB

<img width="1490" height="670" alt="image" src="https://github.com/user-attachments/assets/b18372a8-cb30-496d-8eca-59fcf9d544e0" />

# Prerequisites

Software:
- docker (with compose plugin)
- make


1. Have a self-installed Teleport Cluster or Teleport Cloud instance
2. Have the `editor` role or rights to  `token` and `role`.

Impersonate configuration in role required in Teleport cloud.
```yaml
    impersonate:
      roles:
      - '*'
      - Db
      users:
      - '*'
      - Db
```

You can try out sample roles
```bash
tctl create -f roles/roles.yaml
```
Roles Sample:
  - `example-editor` allows for editing users, roles, tokens and creating signed db certs
  - `example-devops` can access dev labeled ssh node, app and dbs. Can request `example-prodops` access.
  - `example-prodops` can access prod labeled ssh, app and dbs
  - `example-reviewer` can review and approve `example-prodops` access requests

  A access monitoring rule `access_monitoring_rule` will auto approve requests for `example-prodops`
    related resources.

  Users should be unassigned to `access` role for these roles to work properly. `editor` and `auditor` are
  still fine to assign.

# Step 1. Set Makefile

In `Makefile`:

Set the Teleport cluster proxy

TELEPORT_CLUSTER_PROXY ?= teleport.example.com:443

Set the version to match the Teleport Cluster

TELEPORT_CLUSTER_PROXY ?= 9.1.3

Generate a token for db,app, and ssh.

```bash
tctl tokens add --type=db,app,node
```

Update the TELEPORT_TOKEN

```bash
TELEPORT_TOKEN ?= 9.1.3
```



# Step 2. Generate db certs

Generate

```bash
mkdir dbdev
cd dbdev
tctl auth sign --format=db --host=postgresdev --out=server --ttl=12190h
cd ..
mkdir dbprod
cd dbprod
tctl auth sign --format=db --host=postgresprod --out=server --ttl=12190h
```
Now copy these certs into their respective `dbdev` and `dbprod` where you are running your `docker compose` command.

# Step 3. Run Setup, build and start

```bash
make setup
docker compose build
make up
```

# Test resources

If you haven't setup roles you can test out access with the roles under the directory roles.  

The db connections can take a few minutes to be available. 

The ssh nodes and app access are available in the web console or via `tsh`. 


db tests:
```bash
tsh db login --db-user=postgres postgresdev
postgres=# \l
                                    List of databases
      Name       |  Owner   | Encoding  |  Collate   |   Ctype    |   Access privileges   
-----------------+----------+-----------+------------+------------+-----------------------
 postgres        | postgres | UTF8      | en_US.utf8 | en_US.utf8 | 
 sportsdb_sample | postgres | SQL_ASCII | en_US.utf8 | en_US.utf8 | 
 template0       | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |           |            |            | postgres=CTc/postgres
 template1       | postgres | UTF8      | en_US.utf8 | en_US.utf8 | =c/postgres          +
                 |          |           |            |            | postgres=CTc/postgres
postgres=# \connect sportsdb_sample
psql (14.2, server 12.2 (Debian 12.2-2.pgdg100+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_128_GCM_SHA256, bits: 128, compression: off)
You are now connected to database "sportsdb_sample" as user "postgres".    
sportsdb_sample=# select * from american_football_event_states;
```

# Step 4 Setup Kubernetes

The folder `./k8s` contains a `microk8s` setup script `installmicrok8s.sh`.

1. Run this script on a Ubuntu box. Make sure the `clusterrole.yaml` file is in the same folder.

2. Confirm access. The user roles has access to seeing the `example-dev` namespace by default

   `kubectl get ns`
   `kubectl exec -it -n example-dev nginx-dev -- bash`

3. After execing the session can be replayed.
4. The user can request the `example-prod` namespace as well.








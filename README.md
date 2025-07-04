# Apache Doris Docker Cluster

This repository contains a Docker Compose setup for running a high-availability Apache Doris cluster with HAProxy load balancer.

## Architecture

The cluster consists of:
- **3 Frontend (FE) nodes** for metadata management and query coordination
- **3 Backend (BE) nodes** for data storage and computation
- **1 HAProxy load balancer** for high availability and session management

### Network Configuration
- **Network**: `172.20.0.0/24`
- **HAProxy**: `172.20.0.10`
- **FE nodes**: `172.20.0.11`, `172.20.0.12`, `172.20.0.13`
- **BE nodes**: `172.20.0.21`, `172.20.0.22`, `172.20.0.23`

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 8GB RAM
- At least 20GB disk space

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd doris-docker
   ```

2. **Run the setup script (recommended)**
   ```bash
   ./setup.sh
   ```
   This will automatically create all necessary directories and configuration files.

3. **Start the cluster**
   ```bash
   docker-compose up -d
   ```

4. **Check cluster status**
   ```bash
   docker-compose ps
   docker-compose logs -f
   ```

5. **Access the Web UI**
   - Open `http://localhost:8030` in your browser
   - Default credentials: `root` / `(empty password)`

## Setup Script

The included `setup.sh` script helps manage the cluster setup and maintenance:

### Usage
```bash
# Create all necessary directories
./setup.sh setup

# Validate current setup
./setup.sh validate

# Clean up data and logs (preserves config files)
./setup.sh cleanup

# Show help
./setup.sh help
```

### What the setup script does:
- **Creates directories**: All required log, storage, doris-meta, and conf directories
- **Validates setup**: Checks that all required directories exist
- **Sets permissions**: Ensures proper directory permissions

## Services Overview

### HAProxy Load Balancer
- **Container**: `haproxy`
- **Image**: `haproxy:2.9`
- **Ports**: 
  - `8030`: Web UI (with session stickiness)
  - `9030`: MySQL protocol interface
- **Features**: 
  - Session stickiness for Web UI to prevent login issues
  - Round-robin load balancing for MySQL connections

### Frontend (FE) Nodes
- **Containers**: `fe1`, `fe2`, `fe3`
- **Image**: `apache/doris:fe-2.1.9`
- **Role**: Query coordination, metadata management, and cluster management
- **Ports**: 
  - `8030`: Web UI
  - `9030`: MySQL protocol
  - `9010`: Inter-FE communication

### Backend (BE) Nodes
- **Containers**: `be1`, `be2`, `be3`
- **Image**: `apache/doris:be-2.1.9`
- **Role**: Data storage and query execution
- **Ports**:
  - `8040`: Web UI
  - `9050`: Heartbeat service
  - `9060`: RPC communication

## Directory Structure

```
doris-docker/
├── docker-compose.yml          # Main compose file
├── haproxy.cfg                # HAProxy configuration
├── setup.sh                  # Setup and maintenance script
├── fe1/
│   ├── conf/fe.conf           # FE1 configuration
│   ├── doris-meta/            # FE1 metadata storage
│   └── log/                   # FE1 logs
├── fe2/
│   ├── conf/fe.conf           # FE2 configuration
│   ├── doris-meta/            # FE2 metadata storage
│   └── log/                   # FE2 logs
├── fe3/
│   ├── conf/fe.conf           # FE3 configuration
│   ├── doris-meta/            # FE3 metadata storage
│   └── log/                   # FE3 logs
├── be1/
│   ├── conf/be.conf           # BE1 configuration
│   ├── storage/               # BE1 data storage
│   └── log/                   # BE1 logs
├── be2/
│   ├── conf/be.conf           # BE2 configuration
│   ├── storage/               # BE2 data storage
│   └── log/                   # BE2 logs
└── be3/
    ├── conf/be.conf           # BE3 configuration
    ├── storage/               # BE3 data storage
    └── log/                   # BE3 logs
```

## Configuration

### Key Environment Variables

#### FE Nodes
- `FE_ID`: Unique identifier for each FE node (1, 2, 3)
- `FE_SERVERS`: List of all FE nodes with their IPs and edit log ports
  - Format: `fe1:172.20.0.11:9010,fe2:172.20.0.12:9010,fe3:172.20.0.13:9010`

#### BE Nodes
- `FE_SERVERS`: List of FE nodes for BE to connect to
- `BE_ADDR`: BE node's own address for registration

### Network Configuration
- All services use fixed IP addresses within the `172.20.0.0/24` subnet
- This ensures consistent connectivity and avoids hostname resolution issues

## Operations

### Starting the Cluster
```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d fe1 fe2 fe3
docker-compose up -d be1 be2 be3
docker-compose up -d haproxy
```

### Stopping the Cluster
```bash
# Stop all services
docker-compose down

# Stop specific services
docker-compose stop be1 be2 be3
```

### Checking Status
```bash
# View all container status
docker-compose ps

# View logs
docker-compose logs -f fe1
docker-compose logs -f be1
docker-compose logs -f haproxy

# View cluster status via MySQL client
mysql -h 127.0.0.1 -P 9030 -u root -e "SHOW FRONTENDS;"
mysql -h 127.0.0.1 -P 9030 -u root -e "SHOW BACKENDS;"
```

### Scaling Operations
```bash
# Restart specific nodes
docker-compose restart fe1
docker-compose restart be1

# Update configuration and restart
docker-compose up -d --force-recreate fe1
```

## Connecting to Doris

### Web UI Access
- **URL**: `http://localhost:8030`
- **Username**: `root`
- **Password**: (empty)

### MySQL Client Access
```bash
# Connect via MySQL client
mysql -h 127.0.0.1 -P 9030 -u root

# Example queries
SHOW DATABASES;
SHOW FRONTENDS;
SHOW BACKENDS;
```

### JDBC Connection
```java
String url = "jdbc:mysql://localhost:9030/";
String username = "root";
String password = "";
```

## Troubleshooting

### Common Issues

1. **Missing directories or config files**
   - Run `./setup.sh validate` to check what directories are missing
   - Run `./setup.sh setup` to create missing directories
   - Ensure configuration files exist in the conf directories

2. **BE nodes cannot register with FE**
   - Check if FE nodes are running and healthy
   - Verify network connectivity between containers
   - Check FE_SERVERS configuration in BE environment variables

3. **Session timeouts in Web UI**
   - This is resolved by HAProxy session stickiness configuration
   - Clear browser cookies and retry

4. **Container startup failures**
   - Check logs: `docker-compose logs <service-name>`
   - Verify configuration files are correctly mounted
   - Ensure sufficient disk space and memory

5. **Permission denied errors**
   - Run `./setup.sh setup` to fix directory permissions
   - Ensure Docker has access to the project directory

### Health Checks
```bash
# Check if all containers are running
docker-compose ps

# Check container resource usage
docker stats

# Verify network connectivity
docker-compose exec fe1 ping 172.20.0.21
docker-compose exec be1 ping 172.20.0.11
```

### Log Locations
- **FE logs**: `./fe{1,2,3}/log/`
- **BE logs**: `./be{1,2,3}/log/`
- **HAProxy logs**: `docker-compose logs haproxy`

## Performance Tuning

### Resource Allocation
- **FE nodes**: Minimum 2GB RAM each
- **BE nodes**: Minimum 4GB RAM each (adjust based on data size)
- **Storage**: SSD recommended for better performance

### Configuration Tuning
- Adjust JVM heap sizes in `fe.conf` and `be.conf`
- Configure appropriate storage paths in BE configurations
- Tune HAProxy timeouts based on query complexity

## Security Considerations

- Change default root password after initial setup
- Configure firewall rules to restrict access to cluster ports
- Use SSL/TLS for production deployments
- Implement proper backup strategies for metadata and data

## Backup and Recovery

### Metadata Backup
```bash
# Backup FE metadata
docker-compose exec fe1 cp -r /opt/apache-doris/fe/doris-meta /backup/
```

### Data Backup
- Use Doris native backup/restore functionality
- Regular snapshots of BE storage volumes

## Monitoring

### Built-in Monitoring
- FE Web UI: `http://localhost:8030`
- BE Web UI: Access individual BE nodes directly or via port forwarding

### External Monitoring
- Integrate with Prometheus/Grafana for advanced monitoring
- Monitor Docker container metrics
- Set up alerting for cluster health

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

- [Apache Doris Documentation](https://doris.apache.org/docs/)
- [Apache Doris GitHub](https://github.com/apache/doris)
- [Community Forum](https://github.com/apache/doris/discussions)
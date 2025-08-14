# Apache Doris Docker Cluster

This repository contains a Docker Compose setup for running a high-availability Apache Doris cluster with HAProxy load balancer.

## Architecture

The cluster consists of:
- **3 Frontend (FE) nodes** for metadata management and query coordination
- **3 Backend (BE) nodes** for data storage and computation
- **1 HAProxy load balancer** for high availability and session management
- **1 Kafka cluster** for message streaming
- **1 Flink cluster** for stream processing
- **1 Zookeeper instance** for distributed coordination
- **1 MinIO instance** for object storage
- **1 Kafka UI** for Kafka cluster management

### Network Configuration
- **Network**: `172.20.0.0/24`
- **HAProxy**: `172.20.0.10`
- **FE nodes**: `172.20.0.11`, `172.20.0.12`, `172.20.0.13`
- **BE nodes**: `172.20.0.21`, `172.20.0.22`, `172.20.0.23`
- **Flink**: `172.20.0.30`, `172.20.0.31`
- **Zookeeper**: `172.20.0.40`
- **Kafka**: `172.20.0.41`
- **MinIO**: `172.20.0.50`
- **Kafka UI**: `172.20.0.60`

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 8GB RAM
- At least 20GB disk space

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/drgnchan/doris-cluster-docker-compose.git
   cd doris-cluster-docker-compose
   ```

2. **Run the setup script (recommended)**
   ```bash
   ./setup.sh setup
   ```
   This will automatically create all necessary directories and configuration files.

3. **Start the cluster**
   ```bash
   docker-compose up -d
   ```

4. **Access the Web UI**
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

### Kafka UI
- **Container**: `kafka-ui`
- **Image**: `provectuslabs/kafka-ui:latest`
- **Ports**:
  - `9090`: Web UI
- **Role**: Kafka cluster management and monitoring

### Flink
- **Container**: `flink-jobmanager`, `flink-taskmanager`
- **Image**: `flink:1.19`
- **Ports**:
  - `8081`: Web UI
  - `6123`: JobManager RPC
- **Role**: Stream processing and batch processing

### MinIO
- **Container**: `minio`
- **Image**: `minio/minio`
- **Ports**:
  - `9000`: API
  - `9001`: Console
- **Role**: Object storage service

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
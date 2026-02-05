# AWS Infrastructure Architecture

## 全体構成図

```mermaid
flowchart TB
    subgraph Internet
        User[Users]
    end

    subgraph AWS["AWS Cloud"]
        subgraph VPC["VPC (10.0.0.0/16)"]
            subgraph Public["Public Subnets"]
                ALB[Application Load Balancer<br/>HTTP:80 / HTTPS:443]
                NAT[NAT Gateway]
                IGW[Internet Gateway]
            end

            subgraph Private["Private Subnets"]
                subgraph ECS["ECS Cluster (Fargate)"]
                    Task1[Rails Container<br/>AZ-1a]
                    Task2[Rails Container<br/>AZ-1c]
                end

                subgraph RDS_Group["RDS"]
                    RDS[(PostgreSQL<br/>Port: 5432)]
                end
            end
        end

        ECR[ECR<br/>Docker Registry]
        S3[(S3 Bucket<br/>Active Storage)]
        CW[CloudWatch<br/>Logs]
        SSM[SSM Parameter Store<br/>Secrets]
    end

    User -->|HTTP/HTTPS| IGW
    IGW --> ALB
    ALB --> Task1
    ALB --> Task2
    Task1 --> RDS
    Task2 --> RDS
    Task1 --> NAT
    Task2 --> NAT
    NAT --> IGW
    Task1 -.->|Pull Image| ECR
    Task2 -.->|Pull Image| ECR
    Task1 -.->|Upload/Download| S3
    Task2 -.->|Upload/Download| S3
    Task1 -.->|Logs| CW
    Task2 -.->|Logs| CW
    Task1 -.->|Get Secrets| SSM
    Task2 -.->|Get Secrets| SSM
```

## ネットワーク構成

```mermaid
flowchart LR
    subgraph VPC["VPC 10.0.0.0/16"]
        subgraph AZ1["AZ: ap-northeast-1a"]
            Pub1["Public Subnet<br/>10.0.0.0/24"]
            Pri1["Private Subnet<br/>10.0.10.0/24"]
        end

        subgraph AZ2["AZ: ap-northeast-1c"]
            Pub2["Public Subnet<br/>10.0.1.0/24"]
            Pri2["Private Subnet<br/>10.0.11.0/24"]
        end

        IGW2[Internet Gateway]
        NAT2[NAT Gateway]
    end

    Internet2[Internet] <--> IGW2
    IGW2 <--> Pub1
    IGW2 <--> Pub2
    Pub1 --> NAT2
    NAT2 --> Pri1
    NAT2 --> Pri2
```

## デプロイフロー

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant ECR as ECR
    participant ECS as ECS Service
    participant ALB as ALB
    participant RDS as RDS

    Dev->>Dev: docker build
    Dev->>ECR: docker push
    Dev->>ECS: Update Service
    ECS->>ECR: Pull Image
    ECS->>ECS: Start New Tasks
    ECS->>RDS: Run Migrations
    ECS->>ALB: Register Targets
    ALB->>ECS: Health Check
    Note over ALB,ECS: Old tasks drain & stop
```

## セキュリティグループ

```mermaid
flowchart LR
    subgraph SG["Security Groups"]
        subgraph ALB_SG["ALB SG"]
            ALB_IN["Inbound:<br/>80, 443 from 0.0.0.0/0"]
        end

        subgraph ECS_SG["ECS SG"]
            ECS_IN["Inbound:<br/>3000 from ALB SG"]
        end

        subgraph RDS_SG["RDS SG"]
            RDS_IN["Inbound:<br/>5432 from ECS SG"]
        end
    end

    ALB_IN -->|Port 3000| ECS_IN
    ECS_IN -->|Port 5432| RDS_IN
```

## コンポーネント一覧

| Component | Service | Description |
|-----------|---------|-------------|
| Load Balancer | ALB | HTTP/HTTPS トラフィック分散 |
| Container | ECS Fargate | Rails アプリケーション実行 |
| Database | RDS PostgreSQL | データ永続化 |
| Storage | S3 | ファイルストレージ (Active Storage) |
| Registry | ECR | Docker イメージ管理 |
| Secrets | SSM Parameter Store | DB パスワード等の機密情報 |
| Logging | CloudWatch Logs | アプリケーションログ |

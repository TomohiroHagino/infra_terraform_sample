# =============================================================================
# General
# =============================================================================
variable "project_name" {
  description = "プロジェクト名"
  type        = string
  default     = "rails-app"
}

variable "environment" {
  description = "環境名 (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

# =============================================================================
# VPC
# =============================================================================
variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "使用するAZ"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# =============================================================================
# ECS
# =============================================================================
variable "ecs_task_cpu" {
  description = "ECSタスクのCPU (256, 512, 1024, 2048, 4096)"
  type        = number
  default     = 256
}

variable "ecs_task_memory" {
  description = "ECSタスクのメモリ (MB)"
  type        = number
  default     = 512
}

variable "ecs_desired_count" {
  description = "ECSタスクの希望数"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "コンテナのポート"
  type        = number
  default     = 3000
}

# =============================================================================
# RDS
# =============================================================================
variable "db_instance_class" {
  description = "RDSインスタンスクラス"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "rails_app"
}

variable "db_username" {
  description = "データベースユーザー名"
  type        = string
  default     = "rails_user"
}

variable "db_password" {
  description = "データベースパスワード"
  type        = string
  sensitive   = true
}

# =============================================================================
# S3
# =============================================================================
variable "s3_bucket_name" {
  description = "S3バケット名（グローバルでユニークである必要あり）"
  type        = string
}

variable "env" {
  type        = string
  description = "The name of the environment e.g(Prod, Dev)"
}

variable "name" {
  type        = string
  description = "The name of the rds to create"
}

variable "identifier" {
  type        = string
  description = "The rds identifier"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = null
}

variable "db_password" {
  type        = string
  description = "The password of the database"
  default     = null
}

variable "db_username" {
  type        = string
  description = "The username of the database"
  default     = null
}

variable "param_group_name" {
  type        = string
  description = "The parameters group name"
}

variable "replicate_source_db" {
  type        = string
  description = "Source db when creting a replica"
  default     = null
}

variable "allocated_storage" {
  type        = number
  description = "The default allocated storage"
  default     = 10
}

variable "storage_size" {
  type        = number
  description = "The storage size"
  default     = 100
}

variable "storage_type" {
  type        = string
  description = "The storage type"
}

variable "kms_key_id" {
  type        = string
  description = "The KMS encryption key id ARN"
}

variable "multi_az" {
  type        = bool
  description = "Sets muti-availability zone to true or false, default is true"
  default     = true
}

variable "subnets" {
  type        = list(string)
  description = "The subnets associated with the task or service."
}

variable "vpc_id" {
  type        = string
  description = "The VPC id where this rds will run on"
}

variable "security_groups" {
  type        = list(string)
  description = "The extra security groups."
  default     = []
}

variable "db_engine" {
  type        = string
  description = "The database engine e.g(postgres)"
}

variable "engine_version" {
  type        = string
  description = "The database engine version e.g(10.5)"
}

variable "instance_class" {
  type        = string
  description = "The db instance class e.g (db.t3.small)"
}

variable "db_port" {
  type        = number
  description = "The port where the db will exposed on"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

variable "enabled_cloudwatch_logs_exports" {
  default     = null
  type        = list(string)
  description = "A list of logs to export e.g ([postgresql])"
}

variable "allow_public_access" {
  default = false
  type = bool
  description = "Allow public access"
}

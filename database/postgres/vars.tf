variable "aws_region" {
  type = string
}

variable "application" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_master_username" {
  type = string
}

variable "db_master_password" {
  type = string
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "db_port" {
  default     = 5432
  description = "The port to use for the database"
}

variable "skip_final_snapshot" {
  description = "Define if the default of creating a backup upon deletion should be skipped. Default is false"
  default     = false
}

variable "engine_version" {
  type        = string
  description = "RDS engine version"
  default     = null
}
variable "db_instance_class" {
  type        = string
  description = "RDS database instance class"
  default     = "db.t2.micro"
}

variable "db_parameter_group_family" {
  description = "Postgresql parameter group family compatible with chosen engine version"
  default     = "postgres10"
}

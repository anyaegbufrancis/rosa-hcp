## Environment NAME
variable "env" {
  description = " Deployment Environment"
  type        = string
  default     = "rosa-hcp"
}

## Creator Name
variable "created_by" {
  description = "Creator"
  type        = string
  default     = "myname"
}

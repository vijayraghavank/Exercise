variable "rgname" {
    description = "resource grouop name"
    default     = "vijay"
}
variable "location" {
    description = "location name"
    default     = "East Us"
}

variable "vnet_name" {
     description = "name for vnet"
     default     = "tec_vnet"
}
variable "address_space" {
     default     = ["10.0.0.0/16"]
}
variable "subnet_name" {
     default     = "public_subnet"
}
variable "address_prefixes" {
      default     = ["10.0.1.0/24"]
}

variable "external_ip" {
    type        = list(string)
   default      = ["your public ip to allow traffic to server"]
}
variable "numbercount" {
    type          = number
    default       = 2
}

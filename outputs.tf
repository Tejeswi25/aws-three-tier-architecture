output "app_server_instance_id" {
  value = module.EC2.instance_id
}

output "database_endpoint" {
  value = module.database.db_instance_endpoint
}

output "tgw_id" {
  value = module.transit_gateway.tgw_id
}
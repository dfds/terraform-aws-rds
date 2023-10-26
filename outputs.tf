output "sql_cluster_endpoint" {
    value = local.isAurora ? module.db_cluster[0].endpoint : module.db_instance[0].endpoint #aws_db_instance.db_instance[0].endpoint
}

output "sql_cluster_readonly_endpoint" {
    value = local.isAurora ? module.db_cluster[0].reader_endpoint : module.db_instance[0].endpoint
}

output "sql_cluster_port" {
    value = local.isAurora ? module.db_cluster[0].port : module.db_instance[0].port
}

output "sql_database_name" {
    value = local.isAurora ? module.db_cluster[0].database_name : ""
}

output "final_snapshot_identifier" {
    value = local.isAurora ? module.db_cluster[0].final_snapshot_identifier : ""
}

output "sql_proxy_endpoint" {
    value = var.include_proxy ? module.proxy[0].endpoint : ""
}
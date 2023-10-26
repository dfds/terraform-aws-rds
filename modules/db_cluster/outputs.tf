output "id" {
    value = aws_rds_cluster.rds_cluster.id
}

output "endpoint" {
    value = aws_rds_cluster.rds_cluster.endpoint
}

output "reader_endpoint" {
    value = aws_rds_cluster.rds_cluster.reader_endpoint
}

output "port" {
    value = aws_rds_cluster.rds_cluster.port
}

output "database_name" {
    value = aws_rds_cluster.rds_cluster.database_name
}

output "final_snapshot_identifier" {
    value = aws_rds_cluster.rds_cluster.final_snapshot_identifier
}
output "endpoint" {
    value = aws_db_proxy.db_proxy.endpoint
}

output "proxy_security_group_id" {
    value = aws_security_group.proxy_security_group.id
}
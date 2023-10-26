output "arn" {
    value = aws_secretsmanager_secret.secret.arn
}

output "kms_arn" {
    value = aws_kms_key.secret.arn
}
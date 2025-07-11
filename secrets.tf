
resource "aws_secretsmanager_secret" "db_secret" {
  name = "devops-test-db-secret"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.devops-test-db.username
    password = random_password.db.result
    host     = aws_db_instance.devops-test-db.address
    port     = aws_db_instance.devops-test-db.port
    dbname   = aws_db_instance.devops-test-db.db_name
  })
}

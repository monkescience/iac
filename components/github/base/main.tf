resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.github_domain}"
  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f",
    "7560d6f40fa55195f740ee2b1b7c0b4836cbe103"
  ]
}
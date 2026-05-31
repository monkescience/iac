data "aws_iam_policy_document" "vpn" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "vpn" {
  name               = module.this.name
  assume_role_policy = data.aws_iam_policy_document.vpn.json
}

resource "aws_iam_role_policy_attachment" "vpn" {
  role       = aws_iam_role.vpn.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "vpn" {
  name = module.this.name
  role = aws_iam_role.vpn.name
}

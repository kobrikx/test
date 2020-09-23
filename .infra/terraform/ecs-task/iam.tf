resource "aws_iam_role_policy" "this" {
  name   = "${var.env}-${var.name}-ecs-execution-role-policy"
  role   = aws_iam_role.this.id
  policy = jsonencode(local.iam_role_policy)
}

resource "aws_iam_role" "this" {
  name = "${var.env}-${var.name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid"    = "",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "ecs-tasks.amazonaws.com"
        },
        "Action" = "sts:AssumeRole"
      }
    ]
  })
}

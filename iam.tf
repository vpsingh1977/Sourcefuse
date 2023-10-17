provider "aws" {
  region = var.AWS_REGION
}

# Create an IAM policy
resource "aws_iam_policy" "ecs_iam_policy" {
  name = ecs-iam-policy

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        "Action": "s3:*",
        "Resource": [
 	       "arn:aws:s3:::sourcefuses3",
          "arn:aws:s3:::sourcefuses3/*"
       ]
      }
    ]
  })
}

# Create an IAM role
resource "aws_iam_role" "ecs_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "role_policy_attachment" {
  name = "ECS Role"
  policy_arn = aws_iam_policy.ecs_iam_policy.arn
  roles       = [aws_iam_role.ecs_role.name]
}

# Create an IAM policy
resource "aws_iam_policy" "ecs_iam_policy_instance" {
  name = ecs-iam-policy-instance

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      "Effect": "Allow",
      "Action": [
              "ecs:CreateCluster",
              "ecs:DeregisterContainerInstance",
              "ecs:DiscoverPollEndpoint",
              "ecs:Poll",
              "ecs:RegisterContainerInstance",
              "ecs:StartTelemetrySession",
              "ecs:Submit*",
              "ecs:StartTask",
      ],
      "Resource": [
        "*"
      ]
      }
    ]
  })
}

# Create an IAM role
resource "aws_iam_role" "ecs_role_instance" {
  name = "ecsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "role_policy_instance" {
  name = "Instance Policy Attach"
  policy_arn = aws_iam_policy.ecs_iam_policy_instance.arn
  roles       = [aws_iam_role.ecs_role_instance.name]
}

resource "aws_iam_instance_profile" "ecsInstanceRole" {
  name = var.ECS_INSTANCE_ROLE
  role = aws_iam_role.ecs_role_instance.name
}
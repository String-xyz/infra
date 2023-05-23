# General API ECS Cluster
resource "aws_ecs_cluster" "string-core" {
  name = "core"
}

# Since we are using the same AWS account for dev and sandbox, we are creating this cluster here.
# This is not the best practice, but it is the easiest way to get this working.
# In the future, we will create a separate AWS account for sandbox.
resource "aws_ecs_cluster" "sandbox" {
  name = "sandbox-core"
}

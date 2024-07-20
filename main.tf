# Create a VPC
resource "aws_vpc" "devsu_vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "devsu_subnet_public1" {
  vpc_id     = aws_vpc.devsu_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "devsu_subnet_public2" {
  vpc_id     = aws_vpc.devsu_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "devsu_gw" {
  vpc_id = aws_vpc.devsu_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devsu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devsu_gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.devsu_subnet_public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.devsu_subnet_public2.id
  route_table_id = aws_route_table.public.id
}  








resource "aws_security_group" "ecs_service" {
  vpc_id = aws_vpc.devsu_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ecs_service_alb" {
  vpc_id = aws_vpc.devsu_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}









resource "aws_ecr_repository" "my_ecr" {
  name                 = "devsu"
// escaneo de vulne
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_cluster" "devsu_ecs" {
  name = "devsu-cluster"
}

resource "aws_ecs_task_definition" "devsu_task" {
  family                   = "devsu-task"
  container_definitions    = jsonencode([
    {
      name      = "devsu-container"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "devsu_service" {
  name            = "devsu-service"
  cluster         = aws_ecs_cluster.devsu_ecs.id
  task_definition = aws_ecs_task_definition.devsu_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [aws_subnet.devsu_subnet_public1.id, aws_subnet.devsu_subnet_public2.id]
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.devsu_target_group_ecs.arn
    container_name   = "devsu-container"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.devsu_lb_listener]
}







resource "aws_lb" "devsu_lb" {
  name               = "devsu-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_service_alb.id]
  subnets            = [aws_subnet.devsu_subnet_public1.id, aws_subnet.devsu_subnet_public2.id]

  enable_deletion_protection = false
}
resource "aws_lb_target_group" "devsu_target_group_ecs" {
  name     = "devsu-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.devsu_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "devsu_lb_listener" {
  load_balancer_arn = aws_lb.devsu_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devsu_target_group_ecs.arn
  }
}



module "vpc" {
  source               = "./modules/vpc"
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
}

module "ecs" {
  source      = "./modules/ecs"
  vpc_id      = module.vpc.vpc_id
  subnets     = module.vpc.public_subnets
  region      = var.region
}


resource "aws_ecr_repository" "my_ecr" {
  name = "devsu"

  image_scanning_configuration {
    scan_on_push = true
  }
}

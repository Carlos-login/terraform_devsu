output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  value = module.ecs.ecs_cluster_id
}

# Add more outputs as needed

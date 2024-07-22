# terraform_devsu

Este proyecto utiliza Terraform para provisionar y configurar una infraestructura en AWS, incluyendo una VPC, subredes públicas, un clúster ECS y otros recursos relacionados.

## Descripción

Este proyecto de Terraform configura una infraestructura en AWS que incluye:

- Una VPC con subredes públicas.
- Un clúster ECS con tareas y servicios definidos.
- Un balanceador de carga (ALB) configurado para redirigir tráfico HTTP a HTTPS.
- Un repositorio ECR para almacenar imágenes de contenedores.

## Estructura del Proyecto

El proyecto está organizado en los siguientes archivos y módulos:

- `main.tf`: Configuración principal de los módulos VPC y ECS.
- `outputs.tf`: Salidas de la configuración.
- `provider.tf`: Configuración del proveedor AWS.
- `terraform.tfvars`: Variables específicas del entorno.
- `variables.tf`: Definición de variables utilizadas en el proyecto.
- `modules/ecs`: Módulo para configurar ECS.
- `modules/vpc`: Módulo para configurar la VPC y las subredes.

## Instalación

1. **Clona el repositorio**:
   ```sh
    gh repo clone Carlos-login/terraform_devsu



Uso
Configura las variables necesarias en el archivo terraform.tfvars:


    region               = "us-east-1"
    vpc_cidr             = "10.0.0.0/16"
    public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]


Aplica la configuración de Terraform:

- terraform apply

    Esto provisionará todos los recursos definidos en la infraestructura.

Dependencias
   Este proyecto requiere tener instalado:

        -Terraform
        -Una cuenta de AWS con las credenciales configuradas adecuadamente.
## Diagrama de Infraestructura

Este diagrama muestra una vista de alto nivel de la infraestructura creada por Terraform.

```mermaid
graph TD
  A[main.tf]
  B[Variables]
  C[Providers]
  D[Módulos]

  A -->|define| B
  A -->|define| C
  A -->|llama| D

  subgraph "Módulo VPC"
    D1[VPC]
    D2[Subnets]
    D3[Internet Gateway]
    D4[Route Table]
    D -->|crea| D1
    D -->|crea| D2
    D -->|crea| D3
    D -->|crea| D4
  end

  subgraph "Módulo ECS"
    E1[Security Group]
    E2[ECR Repository]
    E3[IAM Role]
    E4[ECS Cluster]
    E5[Task Definition]
    E6[ECS Service]
    E7[Load Balancer]
    E8[LB Listener]
    E9[LB Target Group]
    D -->|crea| E1
    D -->|crea| E2
    D -->|crea| E3
    D -->|crea| E4
    D -->|crea| E5
    D -->|crea| E6
    D -->|crea| E7
    D -->|crea| E8
    D -->|crea| E9
  end


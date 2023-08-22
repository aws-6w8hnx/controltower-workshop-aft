## terraform cloud backend 
terraform {
  backend "remote" {
    organization = "AWS-ControlTower-AFT"

    workspaces {
      name = "aft-workshop-backend-best-practice"
    }
  }
}
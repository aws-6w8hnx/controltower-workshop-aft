module "backend_resources" {
    source = "./modules/backend_services"

    project = "aft"
    env     = "workshop"
    service = "module"
}
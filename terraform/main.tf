module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source = "./modules/ec2"
}

module "kubernates" {
  source = "./modules/kubernates"
}

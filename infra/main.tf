terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

variable "credentials" {}
variable "project" {}
variable "region" {}
variable "zone" {}
variable "website_domain_name" {}


provider "google" {
  credentials = file(var.credentials)
  project = var.project
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  credentials = file(var.credentials)
  region      = var.region
  project     = var.project
}

module "static-assets_cloud-storage-static-website" {
  source  = "simplycubed/static-assets/google//modules/cloud-storage-static-website"
  version = "0.5.2"
  project     = var.project
  website_domain_name = var.website_domain_name
}

resource "google_sourcerepo_repository" "source-repo" {
  name = "${terraform.workspace}-source-repo"
}

resource "google_cloudbuild_trigger" "build-trigger" {
  name = "${terraform.workspace}-trigger"
  location = "global"

  trigger_template {
    branch_name = "main"
    repo_name   = "${terraform.workspace}-source-repo"
  }

  substitutions = {
      _BUCKET_NAME = module.static-assets_cloud-storage-static-website.website_bucket_name
  }

  filename = "cloudbuild.yaml"
}

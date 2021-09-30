# main.tf

terraform {
    required_version = ">=0.14"

    required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
    provider "google" {
        project = "roi-takeoff-user16"
        credentials = file("gcp_keys.json")
        region = "us-central1"
        zone = "us-central1-c"
  }

    resources "google_ project_service" "run_api" {
        service = "run.googleapis.com"

        disable_on_destroy = true
    }

    # Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  name = "app"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "gcr.io/google-samples/hello-app:1.0"
        # due to problem with permissions - I decide to leave hello-app as is
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

}

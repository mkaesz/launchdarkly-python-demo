terraform {
  required_providers {
    launchdarkly = {
      source  = "launchdarkly/launchdarkly"
      version = "~> 2.0"
    }
  }
}

# Configure the LaunchDarkly provider
provider "launchdarkly" {
}

# Create a new project
resource "launchdarkly_project" "demo-project" {
  key  = "demo-project"
  name = "Demo Project"

  environments {
        key   = "staging"
        name  = "Staging"
        color = "000000"
        tags  = ["terraform"]
    }
}

# Create a a kill switch for the new feature
resource "launchdarkly_feature_flag" "new-feature-kill-switch" {
  project_key = launchdarkly_project.demo-project.key
  key         = "new-feature-kill-switch"
  name        = "Kill switch for cool new feature"
  description = "Kill switch for cool new feature"

  variation_type = "boolean"
  variations {
    value       = "true"
    name        = "Enabled"
    description = "Kill switch for new cool new feature is enabled"
  }

  variations {
    value       = "false"
    name        = "Disabled"
    description = "Kill switch for cool new feature is disabled."
  }
}

# Create a new feature flag
resource "launchdarkly_feature_flag" "cool-new-feature" {
  project_key = launchdarkly_project.demo-project.key
  key         = "new-feature"
  name        = "Cool new feature"
  description = "Cool new feature"

  variation_type = "boolean"
  variations {
    value       = "true"
    name        = "Enabled"
    description = "Cool new feature is enabled"
  }

  variations {
    value       = "false"
    name        = "Disabled"
    description = "Cool new feature is disabled."
  }
}

# Add targeting for user "Marc"
resource "launchdarkly_feature_flag_environment" "number_env" {
  flag_id = launchdarkly_feature_flag.cool-new-feature.id
  env_key = launchdarkly_project.demo-project.environments[0].key

  on = true

  targets {
    values    = ["user-key-Marc"]
    variation = 0
  }

  fallthrough {
    variation = 1
  }

  off_variation = 1
}

output "staging_env_key" {
  value = launchdarkly_project.demo-project.environments[0].api_key
  sensitive = true
}

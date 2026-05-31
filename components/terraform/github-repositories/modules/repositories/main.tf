locals {
  defaults = yamldecode(file("${var.repos_path}/_defaults.yaml"))

  repo_files = fileset(var.repos_path, "*.yaml")
  repo_configs = {
    for f in local.repo_files :
    trimsuffix(f, ".yaml") => yamldecode(file("${var.repos_path}/${f}"))
    if f != "_defaults.yaml"
  }

  repositories = {
    for name, config in local.repo_configs : name => merge(
      local.defaults,
      config,
      {
        features              = merge(local.defaults.features, lookup(config, "features", {}))
        merge_options         = merge(local.defaults.merge_options, lookup(config, "merge_options", {}))
        branch_protection     = merge(local.defaults.branch_protection, lookup(config, "branch_protection", {}))
        security_and_analysis = merge(local.defaults.security_and_analysis, lookup(config, "security_and_analysis", {}))
        workflow_permissions  = merge(local.defaults.workflow_permissions, lookup(config, "workflow_permissions", {}))
      }
    )
  }
}

resource "github_repository" "repository" {
  for_each = local.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  auto_init          = each.value.auto_init
  license_template   = each.value.license_template
  archive_on_destroy = each.value.archive_on_destroy

  homepage_url = each.value.homepage_url
  topics       = each.value.topics
  archived     = each.value.archived

  has_issues      = each.value.features.issues
  has_wiki        = each.value.features.wiki
  has_projects    = each.value.features.projects
  has_discussions = each.value.features.discussions

  vulnerability_alerts = each.value.features.vulnerability_alerts

  security_and_analysis {
    secret_scanning {
      status = each.value.security_and_analysis.secret_scanning
    }
    secret_scanning_push_protection {
      status = each.value.security_and_analysis.secret_scanning_push_protection
    }
  }

  allow_merge_commit          = each.value.merge_options.allow_merge_commit
  allow_squash_merge          = each.value.merge_options.allow_squash_merge
  allow_rebase_merge          = each.value.merge_options.allow_rebase_merge
  delete_branch_on_merge      = each.value.merge_options.delete_branch_on_merge
  allow_auto_merge            = each.value.merge_options.allow_auto_merge
  allow_update_branch         = each.value.merge_options.allow_update_branch
  squash_merge_commit_title   = each.value.merge_options.squash_merge_commit_title
  squash_merge_commit_message = each.value.merge_options.squash_merge_commit_message
}

resource "github_branch_default" "default_branch" {
  for_each = local.repositories

  repository = github_repository.repository[each.key].name
  branch     = each.value.default_branch
}

resource "github_repository_ruleset" "branch_protection" {
  for_each = { for k, v in local.repositories : k => v if v.enable_branch_ruleset }

  name        = "branch-protection"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    creation                = false
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = false

    pull_request {
      required_approving_review_count   = each.value.branch_protection.required_approving_review_count
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = true
    }

    dynamic "required_status_checks" {
      for_each = length(each.value.branch_protection.required_status_checks) > 0 ? [1] : []
      content {
        strict_required_status_checks_policy = each.value.branch_protection.strict_required_status_checks
        dynamic "required_check" {
          for_each = each.value.branch_protection.required_status_checks
          content {
            context = required_check.value
          }
        }
      }
    }

    dynamic "required_code_scanning" {
      for_each = length(each.value.branch_protection.required_code_scanning) > 0 ? [1] : []
      content {
        dynamic "required_code_scanning_tool" {
          for_each = each.value.branch_protection.required_code_scanning
          content {
            tool                      = required_code_scanning_tool.value.tool
            alerts_threshold          = required_code_scanning_tool.value.alerts_threshold
            security_alerts_threshold = required_code_scanning_tool.value.security_alerts_threshold
          }
        }
      }
    }
  }
}

resource "github_repository_ruleset" "conventional_commits" {
  for_each = { for k, v in local.repositories : k => v if v.enable_conventional_commits_ruleset }

  name        = "conventional-commits"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    commit_message_pattern {
      operator = "starts_with"
      pattern  = "(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\\(.+\\))?:"
    }
  }
}

resource "github_workflow_repository_permissions" "workflow_permissions" {
  for_each = local.repositories

  repository                       = github_repository.repository[each.key].name
  default_workflow_permissions     = each.value.workflow_permissions.default_permissions
  can_approve_pull_request_reviews = each.value.workflow_permissions.can_approve_pull_request_reviews
}

resource "github_repository_dependabot_security_updates" "security_updates" {
  for_each = { for k, v in local.repositories : k => v if v.features.dependabot_security_updates }

  repository = github_repository.repository[each.key].name
  enabled    = true
}

resource "github_actions_repository_access_level" "access_level" {
  for_each = { for k, v in local.repositories : k => v if v.visibility == "private" || v.visibility == "internal" }

  repository   = github_repository.repository[each.key].name
  access_level = each.value.actions_access_level
}

resource "github_repository_ruleset" "push_protection" {
  for_each = { for k, v in local.repositories : k => v if v.enable_push_ruleset && (v.visibility == "private" || v.visibility == "internal") }

  name        = "push-protection"
  repository  = github_repository.repository[each.key].name
  target      = "push"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  rules {
    max_file_size {
      max_file_size = 10
    }
  }
}

resource "github_repository_ruleset" "tag_protection" {
  for_each = { for k, v in local.repositories : k => v if v.enable_tag_protection_ruleset }

  name        = "tag-protection"
  repository  = github_repository.repository[each.key].name
  target      = "tag"
  enforcement = "active"

  bypass_actors {
    actor_type  = "OrganizationAdmin"
    actor_id    = 0
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    creation = false
    deletion = true
    update   = true
  }
}

resource "github_repository_ruleset" "branch_naming" {
  for_each = { for k, v in local.repositories : k => v if v.enable_branch_naming_ruleset }

  name        = "branch-naming"
  repository  = github_repository.repository[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = ["~DEFAULT_BRANCH", "refs/heads/renovate/*", "refs/heads/release-please--*"]
    }
  }

  rules {
    branch_name_pattern {
      operator = "regex"
      pattern  = "^(feat|fix|chore|docs|refactor|test|ci|build|perf|style|revert)/[a-z0-9-]+$"
    }
  }
}

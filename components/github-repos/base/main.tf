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
        features          = merge(local.defaults.features, lookup(config, "features", {}))
        merge_options     = merge(local.defaults.merge_options, lookup(config, "merge_options", {}))
        branch_protection = merge(local.defaults.branch_protection, lookup(config, "branch_protection", {}))
      }
    )
  }
}

resource "github_repository" "repository" {
  for_each = local.repositories

  name        = each.value.name
  description = lookup(each.value, "description", "")
  visibility  = lookup(each.value, "visibility", "private")

  auto_init        = lookup(each.value, "auto_init", true)
  license_template = lookup(each.value, "license_template", "mit")

  homepage_url = lookup(each.value, "homepage_url", null)
  topics       = lookup(each.value, "topics", [])
  archived     = lookup(each.value, "archived", false)

  has_issues      = each.value.features.issues
  has_wiki        = each.value.features.wiki
  has_projects    = each.value.features.projects
  has_discussions = each.value.features.discussions

  vulnerability_alerts = each.value.features.vulnerability_alerts

  allow_merge_commit          = each.value.merge_options.allow_merge_commit
  allow_squash_merge          = each.value.merge_options.allow_squash_merge
  allow_rebase_merge          = each.value.merge_options.allow_rebase_merge
  delete_branch_on_merge      = each.value.merge_options.delete_branch_on_merge
  allow_auto_merge            = each.value.merge_options.allow_auto_merge
  allow_update_branch         = each.value.merge_options.allow_update_branch
  squash_merge_commit_title   = each.value.merge_options.squash_merge_commit_title
  squash_merge_commit_message = each.value.merge_options.squash_merge_commit_message

  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "github_branch_default" "default_branch" {
  for_each = local.repositories

  repository = github_repository.repository[each.key].name
  branch     = lookup(each.value, "default_branch", "main")
}

resource "github_branch_protection" "default_branch" {
  for_each = { for k, v in local.repositories : k => v if v.enable_branch_protection }

  repository_id = github_repository.repository[each.key].node_id
  pattern       = lookup(each.value, "default_branch", "main")

  required_pull_request_reviews {
    required_approving_review_count = each.value.branch_protection.required_approving_review_count
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    require_last_push_approval      = false
  }

  enforce_admins                  = false
  required_linear_history         = true
  require_conversation_resolution = true
  require_signed_commits          = false
  allows_force_pushes             = false
  allows_deletions                = false
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

    commit_message_pattern {
      operator = "starts_with"
      pattern  = "(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\\(.+\\))?:"
    }
  }
}

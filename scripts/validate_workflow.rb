#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'set'
require 'yaml'

ROOT = Pathname.new(__dir__).join("..").realpath
WORKFLOW_CONFIG_PATH = ROOT.join("workflow_config.yaml")
SKILL_ROOT = ROOT.join("plugins/vibe-up/skills")
AGENT_ROOT = ROOT.join("agents")
NON_ROLE_SKILLS = Set[
  "implementation",
  "initial-setup",
  "proposal",
  "review",
  "swarm"
].freeze

def relative(path)
  Pathname(path).relative_path_from(ROOT).to_s
end

def check(errors, condition, message)
  errors << message unless condition
end

def check_file(errors, path, label)
  check(errors, path.file?, "#{label} is missing: #{relative(path)}")
end

def normalized_string(value)
  value.to_s.strip.downcase
end

config = YAML.safe_load(WORKFLOW_CONFIG_PATH.read, permitted_classes: [], aliases: true) || {}
errors = []

role_definitions = config["role_definitions"]
check(errors, role_definitions.is_a?(Hash) && !role_definitions.empty?, "workflow_config.yaml must define a non-empty role_definitions map")

unless errors.empty?
  warn "Workflow validation failed:"
  errors.each { |error| warn "- #{error}" }
  exit 1
end

alias_owners = {}
priority_owners = {}
skill_owners = {}
agent_owners = {}
registered_skill_names = Set.new
registered_agent_files = Set.new

role_definitions.sort.each do |role_id, definition|
  path = "role_definitions.#{role_id}"
  check(errors, definition.is_a?(Hash), "#{path} must be a map")
  next unless definition.is_a?(Hash)

  %w[agent_file skill aliases selection_hints default_priority].each do |key|
    check(errors, definition.key?(key), "#{path} is missing #{key}")
  end

  agent_file = definition["agent_file"]
  skill_name = definition["skill"]
  aliases = definition["aliases"]
  selection_hints = definition["selection_hints"]
  default_priority = definition["default_priority"]

  check(errors, agent_file.is_a?(String) && !agent_file.empty?, "#{path}.agent_file must be a non-empty string")
  if agent_file.is_a?(String) && !agent_file.empty?
    agent_path = ROOT.join(agent_file)
    check_file(errors, agent_path, "#{path}.agent_file")
    registered_agent_files << agent_file
    if (owner = agent_owners[agent_file])
      errors << "#{path}.agent_file duplicates #{owner}.agent_file: #{agent_file}"
    else
      agent_owners[agent_file] = role_id
    end
  end

  check(errors, skill_name.is_a?(String) && !skill_name.empty?, "#{path}.skill must be a non-empty string")
  if skill_name.is_a?(String) && !skill_name.empty?
    skill_dir = SKILL_ROOT.join(skill_name)
    check(errors, skill_dir.directory?, "#{path}.skill directory is missing: #{relative(skill_dir)}")
    check_file(errors, skill_dir.join("SKILL.md"), "#{path}.skill SKILL.md")
    check_file(errors, skill_dir.join("agents/openai.yaml"), "#{path}.skill agent metadata")
    registered_skill_names << skill_name
    if (owner = skill_owners[skill_name])
      errors << "#{path}.skill duplicates #{owner}.skill: #{skill_name}"
    else
      skill_owners[skill_name] = role_id
    end
  end

  check(errors, default_priority.is_a?(Integer) && default_priority.positive?, "#{path}.default_priority must be a positive integer")
  if default_priority.is_a?(Integer) && default_priority.positive?
    if (owner = priority_owners[default_priority])
      errors << "#{path}.default_priority duplicates #{owner}.default_priority: #{default_priority}"
    else
      priority_owners[default_priority] = role_id
    end
  end

  check(errors, aliases.is_a?(Array) && !aliases.empty?, "#{path}.aliases must be a non-empty list")
  if aliases.is_a?(Array) && !aliases.empty?
    normalized_aliases = aliases.map { |value| normalized_string(value) }
    check(errors, normalized_aliases.none?(&:empty?), "#{path}.aliases must not contain blank values")
    check(errors, normalized_aliases.uniq.length == normalized_aliases.length, "#{path}.aliases must not contain duplicates")
    normalized_aliases.each do |alias_name|
      next if alias_name.empty?

      if (owner = alias_owners[alias_name])
        errors << "#{path}.aliases duplicates #{owner}.aliases entry: #{alias_name}"
      else
        alias_owners[alias_name] = role_id
      end
    end
  end

  check(errors, selection_hints.is_a?(Array) && !selection_hints.empty?, "#{path}.selection_hints must be a non-empty list")
  if selection_hints.is_a?(Array) && !selection_hints.empty?
    normalized_hints = selection_hints.map { |value| normalized_string(value) }
    check(errors, normalized_hints.none?(&:empty?), "#{path}.selection_hints must not contain blank values")
    check(errors, normalized_hints.uniq.length == normalized_hints.length, "#{path}.selection_hints must not contain duplicates")
  end
end

actual_agent_files = Dir.children(AGENT_ROOT).select { |name| name.end_with?(".md") }.map { |name| File.join("agents", name) }.sort
missing_agent_registrations = actual_agent_files - registered_agent_files.to_a
extra_agent_registrations = registered_agent_files.to_a - actual_agent_files
check(errors, missing_agent_registrations.empty?, "Agent files missing role_definitions entries: #{missing_agent_registrations.join(', ')}")
check(errors, extra_agent_registrations.empty?, "Registered agent files missing from repo: #{extra_agent_registrations.join(', ')}")

actual_skill_names = Dir.children(SKILL_ROOT).select do |name|
  skill_dir = SKILL_ROOT.join(name)
  skill_dir.directory? && skill_dir.join("SKILL.md").file?
end.sort
actual_role_skill_names = actual_skill_names.reject { |name| NON_ROLE_SKILLS.include?(name) }
missing_role_skill_registrations = actual_role_skill_names - registered_skill_names.to_a
extra_role_skill_registrations = registered_skill_names.to_a - actual_role_skill_names
check(errors, missing_role_skill_registrations.empty?, "Skill directories missing role_definitions entries or NON_ROLE_SKILLS allowlist entries: #{missing_role_skill_registrations.join(', ')}")
check(errors, extra_role_skill_registrations.empty?, "Registered role skills missing directories: #{extra_role_skill_registrations.join(', ')}")

documentation = config["documentation"] || {}
check(errors, documentation.is_a?(Hash), "documentation must be a map when present")

if documentation["capture_initial_setup_record"]
  initial_setup_path = documentation["initial_setup_record_path"]
  check(errors, initial_setup_path.is_a?(String) && initial_setup_path.start_with?("docs/workflow/"), "documentation.initial_setup_record_path must live under docs/workflow/")
  check_file(errors, ROOT.join("templates/initial_setup_record_template.md"), "Initial setup record template")
  [
    ROOT.join("workflows/01_initial_setup.md"),
    ROOT.join("plugins/vibe-up/skills/initial-setup/SKILL.md")
  ].each do |path|
    check(errors, path.read.include?(initial_setup_path.to_s), "#{relative(path)} must reference #{initial_setup_path}")
  end
end

if documentation["capture_proposal_record"]
  proposal_path = documentation["proposal_record_path"]
  check(errors, proposal_path.is_a?(String) && proposal_path.start_with?("docs/workflow/"), "documentation.proposal_record_path must live under docs/workflow/")
  check_file(errors, ROOT.join("templates/proposal_record_template.md"), "Proposal record template")
  [
    ROOT.join("workflows/02_proposal.md"),
    ROOT.join("plugins/vibe-up/skills/proposal/SKILL.md")
  ].each do |path|
    check(errors, path.read.include?(proposal_path.to_s), "#{relative(path)} must reference #{proposal_path}")
  end
end

if documentation["consult_stage_records_in_review"]
  review_targets = [
    documentation["initial_setup_record_path"],
    documentation["proposal_record_path"]
  ].compact
  check_file(errors, ROOT.join("docs/workflow/README.md"), "Workflow record documentation")
  [
    ROOT.join("workflows/04_review.md"),
    ROOT.join("plugins/vibe-up/skills/review/SKILL.md")
  ].each do |path|
    review_targets.each do |target|
      check(errors, path.read.include?(target), "#{relative(path)} must reference #{target}")
    end
  end
end

readme_path = ROOT.join("README.md")
check_file(errors, readme_path, "README")
if readme_path.file?
  readme = readme_path.read
  actual_skill_names.each do |skill_name|
    snippet = %(/skills/#{skill_name}")
    check(errors, readme.include?(snippet), "README.md active-development install docs do not mention skill directory #{skill_name}")
  end
end

if errors.empty?
  puts "Workflow validation passed."
  puts "Validated #{role_definitions.length} roles, #{actual_skill_names.length} skills, and stage record references."
else
  warn "Workflow validation failed:"
  errors.each { |error| warn "- #{error}" }
  exit 1
end

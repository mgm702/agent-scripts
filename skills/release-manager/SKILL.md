---
name: Release Manager
description: Audit a project end-to-end and produce a release checklist covering deployment, third-party services, environment config, and go-live blockers.
triggers:
  - release checklist
  - ship this
  - production ready
  - go live
  - pre-release audit
  - ready to deploy
---

# Release Manager
Deep codebase research to determine everything needed to get a project into production.

## When to Use
- A project or feature is ready (or nearly ready) to ship
- Unclear what production setup steps remain
- New third-party service integrations need production credentials or configuration
- Deploying to a new environment (AWS, Amplify, Homebrew tap, etc.)
- Pre-release audit before handing off to stakeholders

## Scope Coverage

### APIs / Backend Services
- Target environment: AWS (ECS, Lambda, Elastic Beanstalk, EC2, etc.)
- Identify the deployment model already in use or recommend one based on the project type
- Confirm environment variables, secrets, and parameter store entries needed in production
- Check for database migrations that must run before or after deploy
- Review IAM roles, security groups, and VPC configuration requirements
- Identify any background job workers (Sidekiq, etc.) and how they need to run in production
- Flag health check endpoints and load balancer configuration needs

### Frontend Applications
- Target environment: AWS Amplify
- Confirm build settings (`amplify.yml` or console build config) are correct for the framework
- Identify environment variables that must be set in the Amplify console
- Check domain/subdomain setup and SSL certificate requirements
- Review redirect/rewrite rules needed (e.g. SPA catch-all)
- Confirm CI/CD branch mapping (e.g. `main` → production, `develop` → staging)

### CLIs / Tooling
- Target distribution: Homebrew tap
- Confirm a `Formula` file exists or needs to be created
- Identify the release artifact (binary, tarball) and how it is built
- Check versioning strategy and tagging conventions
- Review tap repository structure and update process
- Confirm SHA256 checksums are generated as part of the release process

### Third-Party Services (Primary Focus When Present)
These block a production release until resolved. Always address these first.

- **Twilio** — production account SID/auth token, phone number provisioning, messaging service SID, webhook URLs pointing to production endpoints, compliance/A2P 10DLC registration if applicable
- **Resend** — production API key, domain verification (DNS records: SPF, DKIM, DMARC), from-address allowlisting
- **Algolia** — production Application ID and API keys (search-only key vs. admin key separation), index configuration promoted from staging, usage plan/quota review
- Flag any other services found in the codebase that have a staging/sandbox vs. production key distinction

## Process

1. **Read broadly** — scan the full project structure, not just entry points. Include config files, CI/CD definitions, `Dockerfile`, `docker-compose`, `Gemfile`/`package.json`, environment variable references, and README files
2. **Trace deployment path** — follow how the app gets built and where it lands (build scripts, CI pipelines, infrastructure-as-code)
3. **Identify all environment-dependent configuration** — every place `ENV[]`, `process.env`, or a credentials file is referenced
4. **Audit third-party integrations** — grep for known service SDK/gem usage and determine if production credentials and account-level setup are in place
5. **Write findings** — produce a `project-release.md` in the working directory (see artifact spec below)

## Release Artifact

Output a `project-release.md` covering the following sections. Every item must be marked with a status:

- `[ ]` — not done, blocks release
- `[~]` — partially done, needs follow-up
- `[x]` — complete

---

### `project-release.md` Structure

```
# Release Checklist: <Project Name>

## Summary
One paragraph describing what is being released, the target environment(s), and the current readiness level.

## Third-Party Services
(Only include services actually used in the project)

### <Service Name>
- [ ] Production credentials obtained and stored securely
- [ ] Account-level setup complete (domain verification, phone provisioning, compliance, etc.)
- [ ] Webhook/callback URLs updated to production endpoints
- [ ] Sending limits / quotas reviewed

## Backend / API Deployment (AWS)
- [ ] Deployment target identified (<ECS / Lambda / EB / EC2>)
- [ ] Production environment variables set (<list each one>)
- [ ] Secrets stored in AWS Secrets Manager or Parameter Store
- [ ] Database migrations ready to run
- [ ] IAM roles and security groups configured
- [ ] Health check endpoint confirmed
- [ ] Background workers accounted for
- [ ] Logging and alerting configured (CloudWatch, etc.)

## Frontend Deployment (AWS Amplify)
- [ ] `amplify.yml` build config verified
- [ ] Production environment variables set in Amplify console (<list each one>)
- [ ] Branch-to-environment mapping confirmed
- [ ] Custom domain and SSL configured
- [ ] Redirect/rewrite rules in place

## CLI Release (Homebrew)
- [ ] Release binary/tarball built and tagged
- [ ] SHA256 checksum generated
- [ ] Homebrew Formula created or updated
- [ ] Tap repository updated and tested with `brew install`

## Pre-Release Verification
- [ ] Staging environment tested against production-equivalent config
- [ ] No hardcoded staging/sandbox API keys remain in code
- [ ] All required DNS records confirmed propagated
- [ ] Rollback plan documented

## Notes
Any additional context, open questions, or follow-up items discovered during research.
```

## Notion Sync

After writing `project-release.md`, sync it to Notion if the MCP is available.

**On creation:**
1. Call `notion_create_page` with the parent page ID from MEMORY.md (`## Notion`)
2. Title: `Release: <Project Name>`
3. Push the full markdown content as blocks
4. Add YAML front matter to the top of the local file:
   ```
   ---
   notion_page_id: <returned id>
   notion_page_url: <returned url>
   ---
   ```

**On checklist updates:**
1. Read `notion_page_id` from front matter
2. Delete the old Notion page via `notion_delete_page`
3. Re-create with updated content and update front matter with new ID/URL

**Rules:**
- If Notion MCP is unavailable, skip silently
- Local file is source of truth; Notion is a mirror

## Prompting Style
- Be specific: name the exact environment variable, file path, or DNS record
- Do not mark an item complete without evidence from the codebase or confirmed configuration
- Flag blockers explicitly — do not bury them in notes
- If a service or deployment target does not apply, omit that section entirely rather than leaving it blank

## Anti-Patterns
- Skimming only the README and assuming setup is done
- Generating a checklist without actually reading the code and config files
- Marking items complete based on assumptions rather than evidence
- Ignoring CI/CD pipeline files — these often reveal gaps in the release process
- Forgetting to separate search-only vs. admin API keys for services like Algolia
- Missing DNS propagation as a blocking step for email/domain-verified services

# OpenClaw on Cloud Run

## Getting Started

This repository contains the configuration and helper tasks to deploy **OpenClaw** on Google Cloud Run using Terraform.  You will be using the `mise` task runner defined in `mise.toml` to simplify common operations.

### Prerequisites

- mise-en-place
- A Google Cloud project with billing enabled

### Initial Setup

Run the setup task to create required configuration files.
Each sub‑task will only create the file if it does not already exist:

```bash
$ mise trust
$ mise install
$ mise setup
```

This will generate:

- `terraform.tfvars` – fill in `project_id`, `region`, `billing_id`, and `my_email`
- `.openclaw/openclaw.json` – agent/gateway settings with a random token
- `.openclaw/agents/main/agent/auth-profiles.json` – stub auth profile

Edit those files with real values before proceeding.

### Configure the project

Make sure the `terraform.tfvars` has valid variables.

## Deploying the service

Terraform is used to create a Cloud Run service called `openclaw-service`.

```bash
# initialize terraform
$ mise tf:init

# preview the changes
$ mise tf:plan

# apply the configuration
$ mise tf:apply
```

## Running and Accessing

Once deployed the service can be reached via a proxy which handles id‑token authentication:

```bash
$ mise run:proxy
```

This listens on `http://localhost:8080` and forwards requests to the Cloud Run URL.

If you want to stop the service use:

```bash
$ mise run:stop
```

## Storage Management

OpenClaw uses a Cloud Storage bucket for persistent data.
The following tasks help sync or clean that data:

- `mise storage:backup [--exec]` – copy bucket contents to `./.openclaw/`
- `mise storage:deploy [--exec]` – push local `./.openclaw` data to the bucket
- `mise storage:clean [--exec]` – delete everything in the bucket

The `--exec` flag actually runs `gcloud`; without it you get a dry run.

## Tips

- gcsfuse-mounted directories are used as-is, so there may be some latency
  - If performance is a concern, consider copying the data locally first
- You can use `gcloud run services proxy` in Pixel Terminal to access the service from a Google Pixel device

# cybervisor-container Agent Guide

## Project Overview

`cybervisor-container` owns the GHCR publishing workflow for the cybervisor container image. The Dockerfile source lives in `../cybervisor/Dockerfile`; this repository should not carry a second Dockerfile copy.

## Files

- `.github/workflows/docker-publish.yml`: Builds and publishes `ghcr.io/<owner>/cybervisor` for pushes to `main`, tags matching `v*`, and pull requests.
- `.dockerignore`: Ignore rules for this workflow repository.

## Release Flow

The `../cybervisor/scripts/publish.sh` helper tags this repository after creating a cybervisor release tag. The workflow then checks out the matching `cybervisor` ref and builds `../cybervisor/Dockerfile` from that source checkout.

## Rules

- Do not add a duplicate Dockerfile here.
- Keep workflow image tags aligned with cybervisor release tags.
- If the Docker build inputs change, update both the workflow and the cybervisor Docker documentation in `../cybervisor/docs/`.

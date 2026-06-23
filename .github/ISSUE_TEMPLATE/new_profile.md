---
name: New stack profile
about: Propose a QRSPI profile for a stack we don't ship yet
title: "profile: <stack name>"
labels: profile
---

## Stack

<!-- e.g. Django/Flask, Go, Rails, .NET, React Native, Next.js -->

## Build/verification verbs

How does one install, typecheck/compile, lint, build, and test this stack?

## Research layers

What are the natural layers to investigate (e.g. routes → handlers → models → migrations)?

## Protected paths & boundary

What must never be edited (generated/vendored trees)? Is there a designated I/O boundary layer?

## Anything unusual

Gotchas the verb table should encode (ordering rules, server restarts, init steps, …).

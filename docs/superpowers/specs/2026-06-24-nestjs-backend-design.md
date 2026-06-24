# NestJS Backend Design

## Background

The repository currently contains a Flutter frontend only. The app already has a repository-based client data layer and a `RemoteContentRepository`, but there is no real backend service, database schema, or seeded production-style content source inside the repo.

The user wants a real backend, not a demo server. The chosen stack is:

- NestJS
- PostgreSQL
- Prisma

The backend should live inside the existing repository under `backend/`.

## Goal

Build the first real backend for the meditation app as a colocated `backend/` service that:

- exposes the read-only REST API already expected by the Flutter frontend,
- persists content in PostgreSQL,
- uses Prisma for schema, migrations, and seed data,
- starts with meaningful seeded content so the frontend can immediately switch from mock data to real API data,
- remains simple enough to extend later with users, auth, playback state, and content operations.

## Non-Goals

This first backend iteration intentionally does not include:

- authentication or JWT,
- admin CMS or management UI,
- media upload pipelines,
- playback streaming infrastructure,
- Docker or cloud deployment automation,
- background jobs,
- multi-tenant design,
- write APIs for content editing.

## Recommended Approach

Use a single NestJS application with light module boundaries:

- `content` module
- `stats` module
- shared Prisma database service

This keeps the first release focused and fast to integrate while still preserving clean boundaries for future expansion.

## Repository Layout

Create a new backend subtree:

- `backend/package.json`
- `backend/nest-cli.json`
- `backend/tsconfig.json`
- `backend/tsconfig.build.json`
- `backend/.env.example`
- `backend/src/main.ts`
- `backend/src/app.module.ts`
- `backend/src/config/`
- `backend/src/database/`
- `backend/src/content/`
- `backend/src/stats/`
- `backend/prisma/schema.prisma`
- `backend/prisma/seed.ts`

This backend remains a normal standalone NestJS app, just stored in the same repository as the Flutter frontend.

## Architecture

### App Module

`AppModule` wires:

- configuration,
- Prisma database module,
- content module,
- stats module.

### Database Layer

Add a Prisma-backed database module with:

- `PrismaService`
  - exposes Prisma client access,
  - manages graceful shutdown hooks where appropriate.

This service should be injected into application services rather than queried directly from controllers.

### Content Module

The `content` module owns:

- `GET /home`
- `GET /meditations`
- `GET /sleep`

Responsibilities:

- fetch and shape meditation content,
- fetch sleep content,
- fetch topic summaries,
- assemble homepage response payloads,
- parse optional list filters for meditations.

### Stats Module

The `stats` module owns:

- `GET /user/stats`

First version behavior:

- returns a single seeded stats record representing the default app user context.

This leaves a clean path to later add `user_id` or auth-derived lookup without rewriting the API surface.

## REST Contract

The backend must support these endpoints:

- `GET /home`
- `GET /meditations`
- `GET /sleep`
- `GET /user/stats`

### GET /home

Response fields:

- `dateText`
- `greetingName`
- `greetingLine`
- `featuredSession`
- `continueSession`
- `topicSummaries`

Composition rules:

- `featuredSession` comes from a meditation record marked `is_featured_home = true`
- `continueSession` is backed by seeded content in the first version
- `topicSummaries` comes from ordered topic summary records

### GET /meditations

Query params:

- optional `category`
- optional `q`

Behavior:

- return only `is_active = true`
- support case-insensitive matching over title, subtitle, instructor, and category for `q`
- preserve stable ordering through `sort_order`

### GET /sleep

Response fields:

- `featuredStory`
- `ambientSounds`
- `sleepItems`

Composition rules:

- `featuredStory` comes from `sleep_items` where `is_featured = true` and `type = story`
- `ambientSounds` comes from `ambient_sounds`
- `sleepItems` comes from the remaining sleep content ordered by `sort_order`

### GET /user/stats

Behavior:

- returns the single seeded default stats record for the first version

## Data Model

### Meditation

Table: `meditations`

Fields:

- `id`
- `title`
- `subtitle`
- `instructor`
- `duration_minutes`
- `category`
- `theme_key`
- `is_featured_home`
- `is_active`
- `sort_order`
- `created_at`
- `updated_at`

Purpose:

- drives explore listing,
- provides the homepage featured session.

### SleepItem

Table: `sleep_items`

Fields:

- `id`
- `title`
- `descriptor`
- `type`
- `duration_minutes`
- `theme_key`
- `is_featured`
- `sort_order`
- `created_at`
- `updated_at`

Purpose:

- stores sleep stories and sleep list items in one table.

### AmbientSound

Table: `ambient_sounds`

Fields:

- `id`
- `title`
- `theme_key`
- `is_featured`
- `sort_order`

Purpose:

- drives the sleep ambient sound strip.

### TopicSummary

Table: `topic_summaries`

Fields:

- `id`
- `name`
- `session_count`
- `theme_key`
- `sort_order`

Purpose:

- drives homepage topic cards.

### UserStats

Table: `user_stats`

Fields:

- `id`
- `streak_days`
- `total_minutes`
- `total_sessions`
- `weekly_completed`
- `weekly_minutes`
- `created_at`
- `updated_at`

First version note:

- `weekly_minutes` can be stored as `Json`
- there is no `user_id` yet

This is acceptable for the first release because the user explicitly scoped this backend version to content-first, read-only APIs.

## Seed Strategy

Seed the backend with meaningful app content so the frontend can immediately render from the real API.

### Meditation Seed Data

Include at least:

- 晨间唤醒
- 深度放松
- 专注当下
- 释放焦虑
- 身体扫描
- 海边的黄昏

### Sleep Seed Data

Include at least:

- 雨夜森林
- 海浪轻语
- 星空之下

### Ambient Sound Seed Data

Include at least:

- 雨声
- 海浪
- 篝火
- 白噪

### Topic Summary Seed Data

Include:

- 放松
- 专注
- 睡眠
- 减压

### User Stats Seed Data

Include:

- `streak_days = 12`
- `total_minutes = 320`
- `total_sessions = 28`
- `weekly_completed = 5`
- `weekly_minutes = [14, 20, 10, 25, 18, 30, 8]`

### Home Personalization Seed Defaults

First version homepage seed should also define:

- greeting name: `林溪`
- greeting line: `愿你今晚拥有平静的睡前时光`
- continue session title: `雨林深处`

These values may live in service-level defaults for version one if introducing an extra table would not improve clarity.

## Module Boundaries

### Content Service

The content service should:

- read meditation, sleep, and topic records,
- map database rows into frontend-ready JSON,
- remain the single place where homepage payload composition happens.

### Stats Service

The stats service should:

- read the default stats row,
- map JSON into the exact frontend contract.

### Controllers

Controllers should stay thin:

- parse route and query input,
- delegate to services,
- return serialized DTOs.

## Environment Variables

Provide:

- `PORT`
- `DATABASE_URL`
- `CORS_ORIGIN`

`CORS_ORIGIN` should allow the Flutter frontend to connect during local development.

## Local Development Flow

Expected setup flow:

1. Start PostgreSQL
2. Install backend dependencies
3. Run Prisma migrations
4. Run Prisma seed
5. Start NestJS dev server
6. Point Flutter to the backend base URL

The backend should be usable with standard commands such as:

- `npm install`
- `npx prisma migrate dev`
- `npx prisma db seed`
- `npm run start:dev`

## Frontend Integration Path

This backend must align with the existing Flutter client contract so the frontend can later switch from:

- `MockContentRepository`

to:

- `RemoteContentRepository(baseUrl: ...)`

with minimal or no payload-shape changes.

## Implementation Scope

This implementation should include:

- backend project scaffold,
- NestJS modules and controllers,
- Prisma schema,
- migration-ready database configuration,
- seed data,
- basic response DTO shaping,
- local development documentation,
- `AGENTS.md` updates describing the backend architecture.

## Risks And Mitigations

### Risk: Over-designing before auth exists

Mitigation:

- keep stats user model simple for version one,
- defer `user_id` until auth is actually introduced.

### Risk: Homepage payload requires data from many sources

Mitigation:

- centralize homepage assembly in the content service,
- do not push aggregation logic into controllers.

### Risk: Seeded personalization feels fake

Mitigation:

- treat first-version personalization as explicit seeded defaults,
- keep the API shape stable so real user data can replace it later.

### Risk: Frontend and backend payloads drift

Mitigation:

- implement backend responses against the already-defined frontend contracts,
- avoid ad hoc field naming changes.

## AGENTS.md Update Requirements

Update `AGENTS.md` to reflect:

- the repository now includes a real NestJS backend under `backend/`
- PostgreSQL + Prisma are the backend persistence stack
- the first backend release is content-first and read-only
- seed data is required for local development
- frontend mock/remote switching should continue to preserve the existing repository contract

## Success Criteria

This work is successful when:

- the repository contains a working `backend/` NestJS service,
- Prisma schema and seed data exist,
- all four agreed endpoints return real database-backed data,
- the frontend can later point to this backend without redesigning its client contract,
- the backend is understandable and maintainable for future auth and progress features.

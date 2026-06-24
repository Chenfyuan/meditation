-- CreateEnum
CREATE TYPE "SleepItemType" AS ENUM ('STORY', 'SOUNDSCAPE');

-- CreateTable
CREATE TABLE "meditations" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "subtitle" TEXT NOT NULL,
    "instructor" TEXT NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "category" TEXT NOT NULL,
    "theme_key" TEXT NOT NULL,
    "is_featured_home" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "meditations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sleep_items" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "descriptor" TEXT NOT NULL,
    "type" "SleepItemType" NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "theme_key" TEXT NOT NULL,
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sleep_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ambient_sounds" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "theme_key" TEXT NOT NULL,
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ambient_sounds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "topic_summaries" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "session_count" INTEGER NOT NULL,
    "theme_key" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "topic_summaries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_stats" (
    "id" TEXT NOT NULL,
    "streak_days" INTEGER NOT NULL,
    "total_minutes" INTEGER NOT NULL,
    "total_sessions" INTEGER NOT NULL,
    "weekly_completed" INTEGER NOT NULL,
    "weekly_minutes" JSONB NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_stats_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "meditations_is_active_sort_order_idx" ON "meditations"("is_active", "sort_order");

-- CreateIndex
CREATE INDEX "meditations_category_idx" ON "meditations"("category");

-- CreateIndex
CREATE INDEX "sleep_items_is_featured_sort_order_idx" ON "sleep_items"("is_featured", "sort_order");

-- CreateIndex
CREATE INDEX "sleep_items_type_sort_order_idx" ON "sleep_items"("type", "sort_order");

-- CreateIndex
CREATE INDEX "ambient_sounds_sort_order_idx" ON "ambient_sounds"("sort_order");

-- CreateIndex
CREATE INDEX "topic_summaries_sort_order_idx" ON "topic_summaries"("sort_order");

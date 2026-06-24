import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient, SleepItemType } from '@prisma/client';

const prisma = new PrismaClient({
  adapter: new PrismaPg({
    connectionString: getDatabaseUrl(),
  }),
});

async function main() {
  await prisma.$transaction([
    prisma.userStats.deleteMany(),
    prisma.topicSummary.deleteMany(),
    prisma.ambientSound.deleteMany(),
    prisma.sleepItem.deleteMany(),
    prisma.meditation.deleteMany(),
  ]);

  await prisma.meditation.createMany({
    data: [
      {
        id: 'meditation-1',
        title: '晨间唤醒',
        subtitle: '平静开启一天',
        instructor: 'Sarah',
        durationMinutes: 8,
        category: '放松',
        themeKey: 'sand',
        sortOrder: 1,
      },
      {
        id: 'meditation-2',
        title: '深度放松',
        subtitle: '释放身体紧张',
        instructor: 'Liam',
        durationMinutes: 15,
        category: '放松',
        themeKey: 'rose',
        sortOrder: 2,
      },
      {
        id: 'meditation-3',
        title: '专注当下',
        subtitle: '提升专注力',
        instructor: 'Mei',
        durationMinutes: 12,
        category: '专注',
        themeKey: 'sage',
        sortOrder: 3,
      },
      {
        id: 'meditation-4',
        title: '释放焦虑',
        subtitle: '缓解日间压力',
        instructor: 'Sarah',
        durationMinutes: 10,
        category: '减压',
        themeKey: 'bronze',
        sortOrder: 4,
      },
      {
        id: 'meditation-5',
        title: '身体扫描',
        subtitle: '睡前深度练习',
        instructor: 'Noah',
        durationMinutes: 20,
        category: '睡眠',
        themeKey: 'twilight',
        sortOrder: 5,
      },
      {
        id: 'meditation-6',
        title: '海边的黄昏',
        subtitle: '舒缓放松',
        instructor: 'Sarah',
        durationMinutes: 10,
        category: '放松',
        themeKey: 'bronze',
        isFeaturedHome: true,
        sortOrder: 6,
      },
      {
        id: 'meditation-7',
        title: '雨林深处',
        subtitle: '沉入安静呼吸',
        instructor: 'Mei',
        durationMinutes: 12,
        category: '睡眠',
        themeKey: 'sage',
        sortOrder: 7,
      },
    ],
  });

  await prisma.sleepItem.createMany({
    data: [
      {
        id: 'sleep-item-1',
        title: '雨夜森林',
        descriptor: '轻柔雨声',
        type: SleepItemType.STORY,
        durationMinutes: 45,
        themeKey: 'cocoa',
        isFeatured: true,
        sortOrder: 1,
      },
      {
        id: 'sleep-item-2',
        title: '海浪轻语',
        descriptor: '舒缓海岸白噪',
        type: SleepItemType.SOUNDSCAPE,
        durationMinutes: 30,
        themeKey: 'ocean',
        sortOrder: 2,
      },
      {
        id: 'sleep-item-3',
        title: '星空之下',
        descriptor: '放松睡前故事',
        type: SleepItemType.STORY,
        durationMinutes: 18,
        themeKey: 'violet',
        sortOrder: 3,
      },
    ],
  });

  await prisma.ambientSound.createMany({
    data: [
      {
        id: 'ambient-1',
        title: '雨声',
        themeKey: 'moss',
        isFeatured: true,
        sortOrder: 1,
      },
      {
        id: 'ambient-2',
        title: '海浪',
        themeKey: 'ocean',
        sortOrder: 2,
      },
      {
        id: 'ambient-3',
        title: '篝火',
        themeKey: 'fire',
        sortOrder: 3,
      },
      {
        id: 'ambient-4',
        title: '白噪',
        themeKey: 'stone',
        sortOrder: 4,
      },
    ],
  });

  await prisma.topicSummary.createMany({
    data: [
      {
        id: 'topic-1',
        name: '放松',
        sessionCount: 12,
        themeKey: 'rose',
        sortOrder: 1,
      },
      {
        id: 'topic-2',
        name: '专注',
        sessionCount: 8,
        themeKey: 'sand',
        sortOrder: 2,
      },
      {
        id: 'topic-3',
        name: '睡眠',
        sessionCount: 15,
        themeKey: 'sage',
        sortOrder: 3,
      },
      {
        id: 'topic-4',
        name: '减压',
        sessionCount: 10,
        themeKey: 'bronze',
        sortOrder: 4,
      },
    ],
  });

  await prisma.userStats.create({
    data: {
      id: 'stats-default',
      streakDays: 12,
      totalMinutes: 320,
      totalSessions: 28,
      weeklyCompleted: 5,
      weeklyMinutes: [14, 20, 10, 25, 18, 30, 8],
    },
  });
}

function getDatabaseUrl(): string {
  const databaseUrl = process.env.DATABASE_URL;

  if (!databaseUrl) {
    throw new Error('DATABASE_URL is not configured');
  }

  return databaseUrl;
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });

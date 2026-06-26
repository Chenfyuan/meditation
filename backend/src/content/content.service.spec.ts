import { SleepItemType } from '@prisma/client';
import { ContentService } from './content.service';

describe('ContentService', () => {
  let database: any;
  let service: ContentService;

  beforeEach(() => {
    database = {
      $transaction: jest.fn(),
      meditation: {
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        findMany: jest.fn(),
      },
      topicSummary: {
        findMany: jest.fn(),
      },
      sleepItem: {
        findFirst: jest.fn(),
        findMany: jest.fn(),
      },
      ambientSound: {
        findMany: jest.fn(),
      },
    };
    service = new ContentService(database);
  });

  it('returns audio URLs in home payload sessions', async () => {
    database.$transaction.mockResolvedValueOnce([
      buildMeditation({
        id: 'featured',
        audioUrl: 'https://audio/featured.mp3',
      }),
      buildMeditation({
        id: 'continue',
        audioUrl: 'https://audio/continue.mp3',
      }),
      [buildTopicSummary()],
    ]);

    const result = await service.getHome();

    expect(result.featuredSession.audioUrl).toBe('https://audio/featured.mp3');
    expect(result.continueSession?.audioUrl).toBe('https://audio/continue.mp3');
  });

  it('returns audio URLs in meditation list items', async () => {
    database.meditation.findMany.mockResolvedValueOnce([
      buildMeditation({
        id: 'meditation-1',
        audioUrl: 'https://audio/one.mp3',
      }),
      buildMeditation({ id: 'meditation-2', audioUrl: null }),
    ]);

    const result = await service.getMeditations({});

    expect(result).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          id: 'meditation-1',
          audioUrl: 'https://audio/one.mp3',
        }),
        expect.objectContaining({
          id: 'meditation-2',
          audioUrl: null,
        }),
      ]),
    );
  });

  it('returns audio URLs in sleep content', async () => {
    database.$transaction.mockResolvedValueOnce([
      buildSleepItem({
        id: 'story',
        audioUrl: 'https://audio/story.mp3',
        type: SleepItemType.STORY,
      }),
      [buildAmbientSound({ id: 'rain', audioUrl: 'https://audio/rain.mp3' })],
      [
        buildSleepItem({
          id: 'soundscape',
          audioUrl: 'https://audio/soundscape.mp3',
          type: SleepItemType.SOUNDSCAPE,
        }),
      ],
    ]);

    const result = await service.getSleep();

    expect(result.featuredStory.audioUrl).toBe('https://audio/story.mp3');
    expect(result.ambientSounds[0].audioUrl).toBe('https://audio/rain.mp3');
    expect(result.sleepItems[0].audioUrl).toBe('https://audio/soundscape.mp3');
  });
});

function buildMeditation(overrides: Record<string, unknown> = {}) {
  return {
    id: 'meditation',
    title: '海边的黄昏',
    subtitle: '舒缓放松',
    instructor: 'Sarah',
    durationMinutes: 10,
    category: '放松',
    themeKey: 'bronze',
    audioUrl: 'https://audio/default.mp3',
    isFeaturedHome: false,
    isActive: true,
    sortOrder: 0,
    createdAt: new Date('2026-06-24T00:00:00Z'),
    updatedAt: new Date('2026-06-24T00:00:00Z'),
    ...overrides,
  };
}

function buildSleepItem(overrides: Record<string, unknown> = {}) {
  return {
    id: 'sleep-item',
    title: '雨夜森林',
    descriptor: '轻柔雨声',
    type: SleepItemType.STORY,
    durationMinutes: 45,
    themeKey: 'cocoa',
    audioUrl: 'https://audio/sleep.mp3',
    isFeatured: false,
    sortOrder: 0,
    createdAt: new Date('2026-06-24T00:00:00Z'),
    updatedAt: new Date('2026-06-24T00:00:00Z'),
    ...overrides,
  };
}

function buildAmbientSound(overrides: Record<string, unknown> = {}) {
  return {
    id: 'ambient',
    title: '雨声',
    themeKey: 'moss',
    audioUrl: 'https://audio/ambient.mp3',
    isFeatured: true,
    sortOrder: 0,
    createdAt: new Date('2026-06-24T00:00:00Z'),
    updatedAt: new Date('2026-06-24T00:00:00Z'),
    ...overrides,
  };
}

function buildTopicSummary(overrides: Record<string, unknown> = {}) {
  return {
    id: 'topic',
    name: '放松',
    sessionCount: 12,
    themeKey: 'rose',
    createdAt: new Date('2026-06-24T00:00:00Z'),
    updatedAt: new Date('2026-06-24T00:00:00Z'),
    ...overrides,
  };
}

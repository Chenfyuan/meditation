import { Injectable, NotFoundException } from '@nestjs/common';
import {
  AmbientSound,
  Meditation,
  Prisma,
  SleepItem,
  SleepItemType,
  TopicSummary,
} from '@prisma/client';
import { DatabaseService } from '../database/database.service';
import {
  AmbientSoundItem,
  ContinueSessionResponse,
  FeaturedSessionResponse,
  HomeResponse,
  MeditationListItem,
  SleepItemResponse,
  SleepResponse,
  SleepStoryResponse,
  TopicSummaryItem,
} from './content.types';

const HOME_GREETING_NAME = '林溪';
const HOME_GREETING_LINE = '愿你今晚拥有平静的睡前时光';
const CONTINUE_SESSION_ID = 'meditation-7';
const CONTINUE_SESSION_REMAINING_SECONDS = 200;

@Injectable()
export class ContentService {
  constructor(private readonly database: DatabaseService) {}

  async getHome(): Promise<HomeResponse> {
    const [featuredSession, continueSession, topicSummaries] =
      await this.database.$transaction([
        this.database.meditation.findFirst({
          where: {
            isActive: true,
            isFeaturedHome: true,
          },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
        this.database.meditation.findUnique({
          where: {
            id: CONTINUE_SESSION_ID,
          },
        }),
        this.database.topicSummary.findMany({
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
      ]);

    if (!featuredSession) {
      throw new NotFoundException('未找到首页推荐冥想内容');
    }

    return {
      dateText: buildDateText(new Date()),
      greetingName: HOME_GREETING_NAME,
      greetingLine: HOME_GREETING_LINE,
      featuredSession: mapFeaturedSession(featuredSession),
      continueSession: continueSession
        ? mapContinueSession(continueSession)
        : null,
      topicSummaries: topicSummaries.map(mapTopicSummary),
    };
  }

  async getMeditations(filters: {
    category?: string;
    query?: string;
  }): Promise<MeditationListItem[]> {
    const category = filters.category?.trim();
    const query = filters.query?.trim();

    const where: Prisma.MeditationWhereInput = {
      isActive: true,
    };

    if (category && category !== '全部') {
      where.category = category;
    }

    if (query) {
      where.OR = [
        { title: { contains: query, mode: 'insensitive' } },
        { subtitle: { contains: query, mode: 'insensitive' } },
        { instructor: { contains: query, mode: 'insensitive' } },
        { category: { contains: query, mode: 'insensitive' } },
      ];
    }

    const meditations = await this.database.meditation.findMany({
      where,
      orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
    });

    return meditations.map(mapMeditation);
  }

  async getSleep(): Promise<SleepResponse> {
    const [featuredStory, ambientSounds, sleepItems] =
      await this.database.$transaction([
        this.database.sleepItem.findFirst({
          where: {
            type: SleepItemType.STORY,
            isFeatured: true,
          },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
        this.database.ambientSound.findMany({
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
        this.database.sleepItem.findMany({
          where: {
            isFeatured: false,
          },
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
        }),
      ]);

    if (!featuredStory) {
      throw new NotFoundException('未找到睡眠推荐内容');
    }

    return {
      featuredStory: mapSleepStory(featuredStory),
      ambientSounds: ambientSounds.map(mapAmbientSound),
      sleepItems: sleepItems.map(mapSleepItem),
    };
  }
}

function mapMeditation(meditation: Meditation): MeditationListItem {
  return {
    id: meditation.id,
    title: meditation.title,
    instructor: meditation.instructor,
    subtitle: meditation.subtitle,
    durationMinutes: meditation.durationMinutes,
    category: meditation.category,
    themeKey: meditation.themeKey,
    audioUrl: meditation.audioUrl,
  };
}

function mapFeaturedSession(meditation: Meditation): FeaturedSessionResponse {
  return {
    id: meditation.id,
    title: meditation.title,
    subtitle: meditation.subtitle,
    instructor: meditation.instructor,
    durationMinutes: meditation.durationMinutes,
    themeKey: meditation.themeKey,
    audioUrl: meditation.audioUrl,
  };
}

function mapContinueSession(meditation: Meditation): ContinueSessionResponse {
  return {
    id: meditation.id,
    title: meditation.title,
    instructor: meditation.instructor,
    durationMinutes: meditation.durationMinutes,
    remainingSeconds: CONTINUE_SESSION_REMAINING_SECONDS,
    themeKey: meditation.themeKey,
    audioUrl: meditation.audioUrl,
  };
}

function mapTopicSummary(topicSummary: TopicSummary): TopicSummaryItem {
  return {
    name: topicSummary.name,
    sessionCount: topicSummary.sessionCount,
    themeKey: topicSummary.themeKey,
  };
}

function mapSleepStory(sleepItem: SleepItem): SleepStoryResponse {
  return {
    id: sleepItem.id,
    title: sleepItem.title,
    descriptor: sleepItem.descriptor,
    durationMinutes: sleepItem.durationMinutes,
    themeKey: sleepItem.themeKey,
    audioUrl: sleepItem.audioUrl,
  };
}

function mapAmbientSound(ambientSound: AmbientSound): AmbientSoundItem {
  return {
    id: ambientSound.id,
    title: ambientSound.title,
    themeKey: ambientSound.themeKey,
    isFeatured: ambientSound.isFeatured,
    audioUrl: ambientSound.audioUrl,
  };
}

function mapSleepItem(sleepItem: SleepItem): SleepItemResponse {
  return {
    id: sleepItem.id,
    title: sleepItem.title,
    type: sleepItem.type === SleepItemType.STORY ? '睡前故事' : '声景',
    durationMinutes: sleepItem.durationMinutes,
    themeKey: sleepItem.themeKey,
    audioUrl: sleepItem.audioUrl,
  };
}

function buildDateText(date: Date): string {
  const weekdays = [
    '星期一',
    '星期二',
    '星期三',
    '星期四',
    '星期五',
    '星期六',
    '星期日',
  ];

  return `${date.getMonth() + 1} 月 ${date.getDate()} 日 · ${weekdays[date.getDay() === 0 ? 6 : date.getDay() - 1]}`;
}

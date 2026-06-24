import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { DatabaseService } from '../database/database.service';
import { UserStatsResponse } from './stats.types';

@Injectable()
export class StatsService {
  constructor(private readonly database: DatabaseService) {}

  async getStats(): Promise<UserStatsResponse> {
    const stats = await this.database.userStats.findFirst({
      orderBy: [{ createdAt: 'desc' }],
    });

    if (!stats) {
      throw new NotFoundException('未找到用户统计数据');
    }

    return {
      streakDays: stats.streakDays,
      totalMinutes: stats.totalMinutes,
      totalSessions: stats.totalSessions,
      weeklyCompleted: stats.weeklyCompleted,
      weeklyMinutes: normalizeWeeklyMinutes(stats.weeklyMinutes),
    };
  }
}

function normalizeWeeklyMinutes(value: Prisma.JsonValue): number[] {
  const minutes = Array.isArray(value)
    ? value
        .map((item) => {
          if (typeof item === 'number') {
            return Math.trunc(item);
          }

          if (typeof item === 'string') {
            return Number.parseInt(item, 10) || 0;
          }

          return 0;
        })
        .slice(0, 7)
    : [];

  while (minutes.length < 7) {
    minutes.push(0);
  }

  return minutes;
}

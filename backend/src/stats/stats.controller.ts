import { Controller, Get } from '@nestjs/common';
import { StatsService } from './stats.service';
import { UserStatsResponse } from './stats.types';

@Controller('user')
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('stats')
  getStats(): Promise<UserStatsResponse> {
    return this.statsService.getStats();
  }
}

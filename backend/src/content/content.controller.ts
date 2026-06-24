import { Controller, Get, Query } from '@nestjs/common';
import { ContentService } from './content.service';
import {
  HomeResponse,
  MeditationListItem,
  SleepResponse,
} from './content.types';

@Controller()
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  @Get('home')
  getHome(): Promise<HomeResponse> {
    return this.contentService.getHome();
  }

  @Get('meditations')
  getMeditations(
    @Query('category') category?: string,
    @Query('q') query?: string,
  ): Promise<MeditationListItem[]> {
    return this.contentService.getMeditations({
      category,
      query,
    });
  }

  @Get('sleep')
  getSleep(): Promise<SleepResponse> {
    return this.contentService.getSleep();
  }
}

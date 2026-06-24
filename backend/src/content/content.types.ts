export type MeditationListItem = {
  id: string;
  title: string;
  instructor: string;
  subtitle: string;
  durationMinutes: number;
  category: string;
  themeKey: string;
};

export type FeaturedSessionResponse = {
  id: string;
  title: string;
  subtitle: string;
  instructor: string;
  durationMinutes: number;
  themeKey: string;
};

export type ContinueSessionResponse = {
  id: string;
  title: string;
  instructor: string;
  durationMinutes: number;
  remainingSeconds: number;
  themeKey: string;
};

export type TopicSummaryItem = {
  name: string;
  sessionCount: number;
  themeKey: string;
};

export type HomeResponse = {
  dateText: string;
  greetingName: string;
  greetingLine: string;
  featuredSession: FeaturedSessionResponse;
  continueSession: ContinueSessionResponse | null;
  topicSummaries: TopicSummaryItem[];
};

export type SleepStoryResponse = {
  id: string;
  title: string;
  descriptor: string;
  durationMinutes: number;
  themeKey: string;
};

export type AmbientSoundItem = {
  id: string;
  title: string;
  themeKey: string;
  isFeatured: boolean;
};

export type SleepItemResponse = {
  id: string;
  title: string;
  type: string;
  durationMinutes: number;
  themeKey: string;
};

export type SleepResponse = {
  featuredStory: SleepStoryResponse;
  ambientSounds: AmbientSoundItem[];
  sleepItems: SleepItemResponse[];
};

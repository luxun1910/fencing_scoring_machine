import type { RecordedVideo } from '../state/matchStore';

export type SaveResult = 'shared' | 'downloaded' | 'cancelled';

export const downloadVideo = (video: RecordedVideo): void => {
  const a = document.createElement('a');
  a.href = video.url;
  a.download = video.fileName;
  a.rel = 'noopener';
  document.body.append(a);
  a.click();
  a.remove();
};

/**
 * Saves a video the way the platform allows: the share sheet on phones (which offers "Save video" to
 * the photo library), otherwise a regular download. Must be called from a user gesture.
 */
export const saveVideo = async (video: RecordedVideo): Promise<SaveResult> => {
  const file = new File([video.blob], video.fileName, { type: video.blob.type });
  if (navigator.canShare?.({ files: [file] })) {
    try {
      await navigator.share({ files: [file] });
      return 'shared';
    } catch (e) {
      if (e instanceof DOMException && e.name === 'AbortError') return 'cancelled';
      // Fall through to download when sharing fails for other reasons.
    }
  }
  downloadVideo(video);
  return 'downloaded';
};

import { create } from 'zustand';
import { createJSONStorage, persist, type StateStorage } from 'zustand/middleware';

export type PreviewSize = 1 | 2 | 3;
export type PreviewPosition = 'left' | 'right';

export interface Settings {
  videoEnable: boolean;
  videoAutoSave: boolean;
  /** Flex weight of the camera preview: S=1, M=2, L=3. */
  videoPreviewSize: PreviewSize;
  /** Side of the camera preview when the screen is landscape. */
  videoPreviewPosition: PreviewPosition;
  doubleButtonEnable: boolean;
  matchNumberCountEnable: boolean;
  /** P-red / P-black cards for unwillingness to fight (FIE t.124). */
  pCardEnable: boolean;
}

export const defaultSettings: Settings = {
  videoEnable: true,
  videoAutoSave: false,
  videoPreviewSize: 2,
  videoPreviewPosition: 'right',
  doubleButtonEnable: true,
  matchNumberCountEnable: false,
  pCardEnable: false,
};

interface SettingsStore extends Settings {
  set: <K extends keyof Settings>(key: K, value: Settings[K]) => void;
}

/** localStorage that degrades to "nothing persisted" when storage is blocked (private mode etc.). */
const safeLocalStorage: StateStorage = {
  getItem: (name) => {
    try {
      return localStorage.getItem(name);
    } catch {
      return null;
    }
  },
  setItem: (name, value) => {
    try {
      localStorage.setItem(name, value);
    } catch {
      // Settings simply won't survive a reload.
    }
  },
  removeItem: (name) => {
    try {
      localStorage.removeItem(name);
    } catch {
      // ignore
    }
  },
};

export const useSettings = create<SettingsStore>()(
  persist(
    (set) => ({
      ...defaultSettings,
      set: (key, value) => set({ [key]: value }),
    }),
    {
      name: 'fsm-settings',
      version: 1,
      storage: createJSONStorage(() => safeLocalStorage),
      partialize: (s): Settings => ({
        videoEnable: s.videoEnable,
        videoAutoSave: s.videoAutoSave,
        videoPreviewSize: s.videoPreviewSize,
        videoPreviewPosition: s.videoPreviewPosition,
        doubleButtonEnable: s.doubleButtonEnable,
        matchNumberCountEnable: s.matchNumberCountEnable,
        pCardEnable: s.pCardEnable,
      }),
    },
  ),
);

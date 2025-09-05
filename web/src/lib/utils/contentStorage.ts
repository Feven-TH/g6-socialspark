import { v4 as uuidv4 } from "uuid";
import { StoryboardShot } from "@/lib/types/api";

export interface ContentData {
  id: string;
  caption: string;
  hashtags: string[];
  imageUrl?: string;
  videoUrl?: string;
  platform: string;
  contentType: string;
  title: string;
  createdAt: string;
  storyboard?: StoryboardShot[];
  overlays?: { text: string; position?: string }[];
}

export const STORAGE_KEYS = {
  LIBRARY: "libraryContent",
  SCHEDULER: "schedulerContent",
  EDITOR: "editorContent",
  POST: "postContent",
  EXPORT: "exportDraft",
} as const;

export const contentStorage = {
  // Save content to a specific storage key
  saveContent: (
    key: string,
    content: Omit<ContentData, "id" | "createdAt">
  ): string => {
    try {
      const id = uuidv4();
      const contentWithId: ContentData = {
        ...content,
        id,
        createdAt: new Date().toISOString(),
      };

      localStorage.setItem(key, JSON.stringify(contentWithId));
      return id;
    } catch (error) {
      console.error("Failed to save content:", error);
      throw new Error("Failed to save content");
    }
  },

  getContent: (key: string): ContentData | null => {
    try {
      const stored = localStorage.getItem(key);
      return stored ? JSON.parse(stored) : null;
    } catch (error) {
      console.error("Failed to get content:", error);
      return null;
    }
  },

  findContentById: (id: string): ContentData | null => {
    try {
      // Check all storage keys
      const keys = Object.values(STORAGE_KEYS);
      for (const key of keys) {
        const stored = localStorage.getItem(key);
        if (stored) {
          const content: ContentData = JSON.parse(stored);
          if (content.id === id) {
            return content;
          }
        }
      }

    
      const library = contentStorage.getLibrary();
      const libraryItem = library.find((item) => item.id === id);
      if (libraryItem) {
        return libraryItem;
      }

      return null;
    } catch (error) {
      console.error("Failed to find content:", error);
      return null;
    }
  },

  // Save to library (stores multiple items)
  saveToLibrary: (content: Omit<ContentData, "id" | "createdAt">): string => {
    try {
      const id = uuidv4();
      const library = contentStorage.getLibrary();
      const newContent: ContentData = {
        ...content,
        id,
        createdAt: new Date().toISOString(),
      };

      const updatedLibrary = [...library, newContent];
      localStorage.setItem(
        STORAGE_KEYS.LIBRARY,
        JSON.stringify(updatedLibrary)
      );
      return id;
    } catch (error) {
      console.error("Failed to save to library:", error);
      throw new Error("Failed to save to library");
    }
  },

  getLibrary: (): ContentData[] => {
    try {
      const library = localStorage.getItem(STORAGE_KEYS.LIBRARY);
      return library ? JSON.parse(library) : [];
    } catch (error) {
      console.error("Failed to get library:", error);
      return [];
    }
  },

  // Get specific item from library by ID
  getFromLibrary: (id: string): ContentData | null => {
    const library = contentStorage.getLibrary();
    return library.find((item) => item.id === id) || null;
  },

  // Update content in library
  updateInLibrary: (id: string, updates: Partial<ContentData>): boolean => {
    try {
      const library = contentStorage.getLibrary();
      const index = library.findIndex((item) => item.id === id);

      if (index === -1) return false;

      library[index] = { ...library[index], ...updates };
      localStorage.setItem(STORAGE_KEYS.LIBRARY, JSON.stringify(library));
      return true;
    } catch (error) {
      console.error("Failed to update library item:", error);
      return false;
    }
  },

  removeFromLibrary: (id: string): boolean => {
    try {
      const library = contentStorage.getLibrary();
      const updatedLibrary = library.filter((item) => item.id !== id);
      localStorage.setItem(
        STORAGE_KEYS.LIBRARY,
        JSON.stringify(updatedLibrary)
      );
      return true;
    } catch (error) {
      console.error("Failed to remove from library:", error);
      return false;
    }
  },

  clearAll: (): void => {
    try {
      Object.values(STORAGE_KEYS).forEach((key) => {
        localStorage.removeItem(key);
      });
    } catch (error) {
      console.error("Failed to clear storage:", error);
    }
  },

  getAllContent: (): ContentData[] => {
    try {
      const allContent: ContentData[] = [];

      Object.values(STORAGE_KEYS)
        .filter((key) => key !== STORAGE_KEYS.LIBRARY)
        .forEach((key) => {
          const content = contentStorage.getContent(key);
          if (content) {
            allContent.push(content);
          }
        });

      const library = contentStorage.getLibrary();
      allContent.push(...library);

      return allContent;
    } catch (error) {
      console.error("Failed to get all content:", error);
      return [];
    }
  },
};

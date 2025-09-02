import { LibraryItem, EditorContent, SchedulerContent } from "@/types/library";

// Mock data for development
const mockContent: LibraryItem[] = [
  {
    id: 1,
    title: "Caramel Macadamia Latte",
    type: "image",
    contentType: "image",
    platform: "instagram",
    createdAt: "2024-01-15",
    status: "published",
    engagement: { likes: 45, comments: 8, views: 234 },
    caption: "Try our new Caramel Macadamia Latte! Perfect coffee blend...",
    hashtags: ["AddisAbebaCafe", "EthiopianCoffee", "Latte"],
    videoUrl: "",
    imageUrl: "/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png",
  },
  {
    id: 2,
    title: "Behind the Scenes",
    type: "video",
    contentType: "video",
    platform: "tiktok",
    createdAt: "2024-01-14",
    status: "draft",
    engagement: { likes: 0, comments: 0, views: 0 },
    caption: "Watch how we make our signature latte...",
    hashtags: ["BehindTheScenes", "CoffeeProcess", "Barista"],
    videoUrl: "/short-video-of-latte-being-made.mp4",
    imageUrl: "/short-video-of-latte-being-made.png",
  },
  {
    id: 3,
    title: "Weekend Special",
    type: "image",
    contentType: "image",
    platform: "instagram",
    createdAt: "2024-01-13",
    status: "scheduled",
    engagement: { likes: 0, comments: 0, views: 0 },
    caption: "Weekend vibes with our special blend...",
    hashtags: ["WeekendSpecial", "CoffeeLovers", "Relax"],
    videoUrl: "",
    imageUrl: "/weekend-coffee-special.png",
  },
  {
    id: 4,
    title: "Customer Review",
    type: "image",
    contentType: "image",
    platform: "instagram",
    createdAt: "2024-01-12",
    status: "published",
    engagement: { likes: 67, comments: 12, views: 345 },
    caption: "Amazing feedback from our lovely customers...",
    hashtags: ["CustomerLove", "Reviews", "HappyCustomers"],
    videoUrl: "",
    imageUrl: "/happy-customer-with-coffee.png",
  },
];

class LibraryService {
  private storageKey = "libraryContent";

  // Get all library content
  async getLibraryContent(): Promise<LibraryItem[]> {
    try {
      const stored = localStorage.getItem(this.storageKey);
      if (stored) {
        return JSON.parse(stored);
      } else {
        // Initialize with sample data if no content exists
        localStorage.setItem(this.storageKey, JSON.stringify(mockContent));
        return mockContent;
      }
    } catch (error) {
      console.error("Failed to fetch library content:", error);
      return [];
    }
  }

  // Save library content
  async saveLibraryContent(content: LibraryItem[]): Promise<void> {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(content));
    } catch (error) {
      console.error("Failed to save library content:", error);
      throw error;
    }
  }

  // Delete a library item
  async deleteLibraryItem(id: number): Promise<void> {
    try {
      const content = await this.getLibraryContent();
      const updatedContent = content.filter((item) => item.id !== id);
      await this.saveLibraryContent(updatedContent);
    } catch (error) {
      console.error("Failed to delete library item:", error);
      throw error;
    }
  }

  // Get a specific library item by ID
  async getLibraryItem(id: number): Promise<LibraryItem | null> {
    try {
      const content = await this.getLibraryContent();
      return content.find((item) => item.id === id) || null;
    } catch (error) {
      console.error("Failed to fetch library item:", error);
      return null;
    }
  }

  // Update a library item
  async updateLibraryItem(
    id: number,
    updates: Partial<LibraryItem>
  ): Promise<LibraryItem | null> {
    try {
      const content = await this.getLibraryContent();
      const itemIndex = content.findIndex((item) => item.id === id);

      if (itemIndex === -1) return null;

      content[itemIndex] = { ...content[itemIndex], ...updates };
      await this.saveLibraryContent(content);

      return content[itemIndex];
    } catch (error) {
      console.error("Failed to update library item:", error);
      throw error;
    }
  }
  // Save editor content
  saveEditorContent(content: EditorContent): void {
    try {
      localStorage.setItem("editorContent", JSON.stringify(content));
    } catch (error) {
      console.error("Failed to save editor content:", error);
      throw error;
    }
  }

  // Save scheduler content
  saveSchedulerContent(content: SchedulerContent): void {
    try {
      localStorage.setItem("schedulerContent", JSON.stringify(content));
    } catch (error) {
      console.error("Failed to save scheduler content:", error);
      throw error;
    }
  }
}

export const libraryService = new LibraryService();
export default libraryService;

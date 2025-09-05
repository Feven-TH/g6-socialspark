import { LibraryItem, EditorContent, SchedulerContent } from "@/types/library";

// Mock data for development
const mockContent: LibraryItem[] = [
  {
    id: "1",
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
    id: "2",
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
    id: "3",
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
    id: "4",
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
  async deleteLibraryItem(id: string): Promise<void> {
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
  async getLibraryItem(id: string): Promise<LibraryItem | null> {
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
    id: string,
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
  // Export image
  async exportImage(item: LibraryItem): Promise<Blob> {
    return new Promise((resolve, reject) => {
      try {
        const canvas = document.createElement("canvas");
        const ctx = canvas.getContext("2d");
        const img = new window.Image();

        img.onload = () => {
          canvas.width = img.width;
          canvas.height = img.height;
          ctx?.drawImage(img, 0, 0);

          // Add text overlay if needed
          if (ctx) {
            ctx.fillStyle = "white";
            ctx.font = "16px Arial";
            ctx.fillText(item.caption, 10, img.height - 20);
          }

          canvas.toBlob((blob) => {
            if (blob) {
              resolve(blob);
            } else {
              reject(new Error("Failed to create blob"));
            }
          }, "image/png");
        };

        img.onerror = () => reject(new Error("Failed to load image"));
        img.src = item.imageUrl;
      } catch (error) {
        reject(error);
      }
    });
  }

  async downloadVideo(url: string, filename: string) {
    const a = document.createElement("a");
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  // Copy text to clipboard
  async copyToClipboard(text: string): Promise<void> {
    try {
      await navigator.clipboard.writeText(text);
    } catch (error) {
      console.error("Failed to copy text:", error);
      throw error;
    }
  }

  // Filter content based on search and filters
  filterContent(
    content: LibraryItem[],
    searchQuery: string,
    filterType: string,
    filterPlatform: string
  ): LibraryItem[] {
    return content.filter((item) => {
      const matchesSearch =
        item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.caption.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesType = filterType === "all" || item.type === filterType;
      const matchesPlatform =
        filterPlatform === "all" || item.platform === filterPlatform;

      return matchesSearch && matchesType && matchesPlatform;
    });
  }
}

export const libraryService = new LibraryService();
export default libraryService;

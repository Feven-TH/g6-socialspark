import { useState, useEffect, useCallback } from "react";
import { LibraryItem, ToastState, FilterState } from "@/types/library";
import libraryService from "@/services/libraryService";

export function useLibrary() {
  const [libraryContent, setLibraryContent] = useState<LibraryItem[]>([]);
  const [filteredContent, setFilteredContent] = useState<LibraryItem[]>([]);
  const [filters, setFilters] = useState<FilterState>({
    searchQuery: "",
    filterType: "all",
    filterPlatform: "all",
    viewMode: "grid",
  });
  const [copiedId, setCopiedId] = useState<number | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<LibraryItem | null>(null);
  const [toast, setToast] = useState<ToastState>({
    show: false,
    message: "",
    type: "success",
  });

  // Load content on mount
  useEffect(() => {
    loadLibraryContent();
  }, []);

  // Filter content when filters change
  useEffect(() => {
    const filtered = libraryService.filterContent(
      libraryContent,
      filters.searchQuery,
      filters.filterType,
      filters.filterPlatform
    );
    setFilteredContent(filtered);
  }, [libraryContent, filters]);

  const loadLibraryContent = useCallback(async () => {
    try {
      const content = await libraryService.getLibraryContent();
      setLibraryContent(content);
    } catch (error) {
      console.error("Failed to load library content:", error);
      showToast("Failed to load library content", "error");
    }
  }, []);

  const showToast = useCallback(
    (message: string, type: "success" | "error") => {
      setToast({ show: true, message, type });
      setTimeout(
        () => setToast({ show: false, message: "", type: "success" }),
        3000
      );
    },
    []
  );

  const handleFiltersChange = useCallback(
    (newFilters: Partial<FilterState>) => {
      setFilters((prev) => ({ ...prev, ...newFilters }));
    },
    []
  );

  const handleDeleteClick = useCallback((item: LibraryItem) => {
    setItemToDelete(item);
    setDeleteDialogOpen(true);
  }, []);

  const handleDeleteConfirm = useCallback(async () => {
    if (!itemToDelete) return;

    try {
      await libraryService.deleteLibraryItem(itemToDelete.id);
      await loadLibraryContent(); // Reload content
      setDeleteDialogOpen(false);
      setItemToDelete(null);
      showToast(
        `"${itemToDelete.title}" has been deleted successfully`,
        "success"
      );
    } catch (error) {
      showToast("Failed to delete item", "error");
    }
  }, [itemToDelete, loadLibraryContent, showToast]);

  const handleDeleteCancel = useCallback(() => {
    setDeleteDialogOpen(false);
    setItemToDelete(null);
  }, []);

  const handleExportAsImage = useCallback(
    async (item: LibraryItem) => {
      try {
        const blob = await libraryService.exportImage(item);
        const url = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = url;
        link.download = `${item.title.replace(/\s+/g, "_")}.png`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
        showToast(`"${item.title}" exported as image successfully`, "success");
      } catch (error) {
        showToast("Failed to export as image", "error");
      }
    },
    [showToast]
  );

  const handleCopyToClipboard = useCallback(
    async (item: LibraryItem) => {
      const textToCopy = `${item.caption}\n\n${item.hashtags
        .map((tag) => `#${tag}`)
        .join(" ")}`;

      try {
        await libraryService.copyToClipboard(textToCopy);
        setCopiedId(item.id);
        setTimeout(() => setCopiedId(null), 2000);
        showToast("Caption and hashtags copied to clipboard", "success");
      } catch (error) {
        showToast("Failed to copy to clipboard", "error");
      }
    },
    [showToast]
  );

  const handleCopyHashtagsOnly = useCallback(
    async (item: LibraryItem) => {
      const hashtagsText = item.hashtags.map((tag) => `#${tag}`).join(" ");

      try {
        await libraryService.copyToClipboard(hashtagsText);
        showToast("Hashtags copied to clipboard", "success");
      } catch (error) {
        showToast("Failed to copy hashtags", "error");
      }
    },
    [showToast]
  );

  const handleEdit = useCallback((item: LibraryItem) => {
    libraryService.saveEditorContent({
      id: item.id,
      caption: item.caption,
      hashtags: item.hashtags,
      imageUrl: item.imageUrl,
      platform: item.platform,
      contentType: item.type,
      title: item.title,
    });
    window.location.href = `/editor/${item.id}`;
  }, []);

  const handleSchedule = useCallback((item: LibraryItem) => {
    libraryService.saveSchedulerContent({
      id: item.id,
      caption: item.caption,
      hashtags: item.hashtags,
      imageUrl: item.imageUrl,
      platform: item.platform,
      contentType: item.type,
      title: item.title,
    });
    window.location.href = `/schedule/${item.id}`;
  }, []);

  const clearSearch = useCallback(() => {
    handleFiltersChange({ searchQuery: "" });
  }, [handleFiltersChange]);

  return {
    // State
    libraryContent,
    filteredContent,
    filters,
    copiedId,
    deleteDialogOpen,
    itemToDelete,
    toast,

    // Actions
    handleFiltersChange,
    handleDeleteClick,
    handleDeleteConfirm,
    handleDeleteCancel,
    handleExportAsImage,
    handleCopyToClipboard,
    handleCopyHashtagsOnly,
    handleEdit,
    handleSchedule,
    clearSearch,
    showToast,
  };
}

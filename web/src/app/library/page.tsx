"use client";
import Header from "@/components/commonheader";
import SearchAndFilters from "@/components/SearchAndFilters";
import ContentCard from "@/components/ContentCard";
import ContentListItem from "@/components/ContentListItem";
import DeleteDialog from "@/components/DeleteDialog";
import Toast from "@/components/Toast";
import EmptyState from "@/components/EmptyState";
import { useLibrary } from "@/hooks/useLibrary";
import { Sparkles } from "lucide-react";
import { Button } from "@/components/button";

export default function LibraryPage() {
  const {
    filteredContent,
    filters,
    copiedId,
    deleteDialogOpen,
    itemToDelete,
    toast,
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
  } = useLibrary();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                <Sparkles className="w-6 h-6 text-primary-foreground" />
              </div>
              <div>
                <h1 className="text-xl font-black font-montserrat text-foreground">
                  Content Library
                </h1>
                <p className="text-sm text-muted-foreground">
                  Manage your created content
                </p>
              </div>
            </div>

            <Button asChild>
              <a href="/dashboard">
                <Sparkles className="w-4 h-4 mr-2" />
                Create New
              </a>
            </Button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Filters and Search */}
        <SearchAndFilters
          filters={filters}
          onFiltersChange={handleFiltersChange}
        />

        {/* Content Grid/List */}
        {filters.viewMode === "grid" ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {filteredContent.map((item) => (
              <ContentCard
                key={item.id}
                item={item}
                copiedId={copiedId}
                onExport={handleExportAsImage}
                onCopy={handleCopyToClipboard}
                onEdit={handleEdit}
                onSchedule={handleSchedule}
                onDelete={handleDeleteClick}
              />
            ))}
          </div>
        ) : (
          // List view
          <div className="space-y-4">
            {filteredContent.map((item) => (
              <ContentListItem
                key={item.id}
                item={item}
                copiedId={copiedId}
                onExport={handleExportAsImage}
                onCopy={handleCopyToClipboard}
                onCopyHashtags={handleCopyHashtagsOnly}
                onEdit={handleEdit}
                onSchedule={handleSchedule}
                onDelete={handleDeleteClick}
              />
            ))}
          </div>
        )}

        {/* Empty State */}
        {filteredContent.length === 0 && (
          <EmptyState
            searchQuery={filters.searchQuery}
            onClearSearch={clearSearch}
          />
        )}

        {/* Delete Confirmation Dialog */}
        <DeleteDialog
          isOpen={deleteDialogOpen}
          itemToDelete={itemToDelete}
          onConfirm={handleDeleteConfirm}
          onCancel={handleDeleteCancel}
        />

        {/* Toast Notifications */}
        <Toast toast={toast} />
      </div>
    </div>
  );
}

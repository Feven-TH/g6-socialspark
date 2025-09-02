"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "../../../components/card";
import { Textarea } from "../../../components/textarea";
import { Badge } from "../../../components/badge";
import { Button } from "../../../components/button";
import Toast from "@/components/Toast";
import {
  ImageIcon,
  Camera,
  Hash,
  Type,
  Play,
  ArrowLeft,
  Download,
  Copy,
  Check,
  Clock,
  Edit,
} from "lucide-react";
import { ContentItem, ToastState } from "@/types/library";
import libraryService from "@/services/libraryService";

export default function Page() {
  const params = useParams();
  const id = params?.id;
  const router = useRouter();
  const [content, setContent] = useState<ContentItem | null>(null);
  const [copiedId, setCopiedId] = useState<number | null>(null);
  const [toast, setToast] = useState<ToastState>({
    show: false,
    message: "",
    type: "success",
  });

  useEffect(() => {
    if (!id) return;

    const loadContent = async () => {
      try {
        const item = await libraryService.getLibraryItem(Number(id));
        if (item) {
          setContent({
            id: item.id,
            title: item.title,
            caption: item.caption,
            hashtags: item.hashtags,
            imageUrl: item.imageUrl,
            videoUrl: item.videoUrl,
            platform: item.platform,
            type: item.type,
          });
        }
      } catch (error) {
        console.error("Failed to load content:", error);
        showToast("Failed to load content", "error");
      }
    };

    loadContent();
  }, [id]);

  const showToast = (message: string, type: "success" | "error") => {
    setToast({ show: true, message, type });
    setTimeout(
      () => setToast({ show: false, message: "", type: "success" }),
      3000
    );
  };

  const handleExportAsImage = async () => {
    if (!content) return;

    try {
      const blob = await libraryService.exportImage({
        ...content,
        videoUrl: content.videoUrl || "",
        createdAt: new Date().toISOString(),
        status: "draft",
        engagement: { likes: 0, comments: 0, views: 0 },
        contentType: content.type,
      });

      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `${content.title.replace(/\s+/g, "_")}.png`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      showToast(`"${content.title}" exported as image successfully`, "success");
    } catch (error) {
      showToast("Failed to export as image", "error");
    }
  };

  const handleCopyToClipboard = async () => {
    if (!content) return;

    const textToCopy = `${content.caption}\n\n${content.hashtags
      .map((tag) => `#${tag}`)
      .join(" ")}`;

    try {
      await libraryService.copyToClipboard(textToCopy);
      setCopiedId(content.id);
      setTimeout(() => setCopiedId(null), 2000);
      showToast("Caption and hashtags copied to clipboard", "success");
    } catch (error) {
      showToast("Failed to copy to clipboard", "error");
    }
  };

  const handleEdit = () => {
    if (!content) return;

    libraryService.saveEditorContent({
      id: content.id,
      caption: content.caption,
      hashtags: content.hashtags,
      imageUrl: content.imageUrl,
      platform: content.platform,
      contentType: content.type,
      title: content.title,
    });
    window.location.href = `/editor/${content.id}`;
  };

  const handleSchedule = () => {
    if (!content) return;

    libraryService.saveSchedulerContent({
      id: content.id,
      caption: content.caption,
      hashtags: content.hashtags,
      imageUrl: content.imageUrl,
      platform: content.platform,
      contentType: content.type,
      title: content.title,
    });
    window.location.href = `/schedule/${content.id}`;
  };

  if (!content) {
    return (
      <div className="p-8 text-center text-muted-foreground">
        No content to display.
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background p-8">
      {/* Back Button */}
      <button
        onClick={() => router.push("/library")}
        className="flex items-center gap-2 mb-4 text-sm text-primary font-medium hover:text-primary-foreground transition"
      >
        <ArrowLeft className="w-4 h-4" />
        Back to Library
      </button>

      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">{content.title}</h1>

        {/* Action Buttons */}
        <div className="flex gap-2">
          <Button
            size="sm"
            variant="outline"
            onClick={handleEdit}
            title="Edit snap"
          >
            <Edit className="w-4 h-4 mr-2" />
            Edit
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={handleExportAsImage}
            title="Export as image"
          >
            <Download className="w-4 h-4 mr-2" />
            Export
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={handleCopyToClipboard}
            title="Copy caption and hashtags"
          >
            {copiedId === content.id ? (
              <Check className="w-4 h-4 mr-2 text-green-600" />
            ) : (
              <Copy className="w-4 h-4 mr-2" />
            )}
            Copy All
          </Button>

          <Button
            size="sm"
            variant="outline"
            onClick={handleSchedule}
            title="Schedule snap"
          >
            <Clock className="w-4 h-4 mr-2" />
            Schedule
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Camera className="w-5 h-5 text-secondary" />
            Generated Content
          </CardTitle>
        </CardHeader>

        <CardContent className="space-y-6">
          <div className="grid md:grid-cols-2 gap-6">
            {/* Left: Caption & Hashtags */}
            <div className="space-y-4">
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Type className="w-4 h-4" />
                  <label className="font-medium">Caption</label>
                </div>
                <Textarea
                  value={content.caption}
                  readOnly
                  className="min-h-[120px]"
                />
              </div>

              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Hash className="w-4 h-4" />
                  <label className="font-medium">Hashtags</label>
                </div>
                <div className="flex flex-wrap gap-2">
                  {content.hashtags.map((tag, idx) => (
                    <Badge key={idx} variant="secondary" className="text-xs">
                      #{tag}
                    </Badge>
                  ))}
                </div>
              </div>
            </div>

            {/* Right: Visual Preview */}
            <div>
              <div className="flex items-center gap-2 mb-2">
                <ImageIcon className="w-4 h-4" />
                <label className="font-medium">Preview</label>
              </div>
              <div className="aspect-square bg-muted rounded-lg overflow-hidden flex items-center justify-center relative">
                {content.type === "image" ? (
                  <Image
                    src={content.imageUrl || "/placeholder.svg"}
                    alt={content.title}
                    fill
                    className="object-cover"
                  />
                ) : (
                  <>
                    {content.videoUrl ? (
                      <video
                        src={content.videoUrl}
                        controls
                        className="w-full h-full object-cover"
                      />
                    ) : (
                      <div className="flex flex-col items-center justify-center text-muted-foreground">
                        <Play className="w-12 h-12 mb-2" />
                        <span>Video Preview</span>
                      </div>
                    )}
                  </>
                )}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Toast Notifications */}
      <Toast toast={toast} />
    </div>
  );
}

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
import { ImageIcon, Camera, Hash, Type, Play, ArrowLeft } from "lucide-react";

type ContentItem = {
  id: number;
  title: string;
  caption: string;
  hashtags: string[];
  imageUrl: string;
  videoUrl?: string;
  platform: string;
  type: string;
};

export default function Page() {
  const params = useParams();
  const id = params?.id;
  const router = useRouter();
  const [content, setContent] = useState<ContentItem | null>(null);

  useEffect(() => {
    if (!id) return;

    const stored = localStorage.getItem("libraryContent");
    if (stored) {
      const items: ContentItem[] = JSON.parse(stored);
      const selected = items.find((item) => item.id.toString() === id);
      if (selected) setContent(selected);
    }
  }, [id]);

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

      <h1 className="text-2xl font-bold mb-6">{content.title}</h1>

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
    </div>
  );
}

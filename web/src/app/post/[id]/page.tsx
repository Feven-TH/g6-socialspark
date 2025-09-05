"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Button } from "@/components/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/card";
import { Label } from "@/components/label";
import Toast from "@/components/Toast";
import { useSchedulePostMutation } from "@/lib/redux/services/api";
import type { ToastState, LibraryItem } from "@/types/library";
import { libraryService } from "@/services/libraryService";

const PLATFORMS = ["instagram", "facebook", "pinterest"] as const;

export default function PostSchedulePage() {
  const params = useParams() as { id: string | undefined };
  const router = useRouter();

  const [assetId, setAssetId] = useState<string>("");
  const [platform, setPlatform] =
    useState<(typeof PLATFORMS)[number]>("instagram");
  const [postText, setPostText] = useState<string>("");
  const [runAt, setRunAt] = useState<string>("");
  const [item, setItem] = useState<LibraryItem | null>(null);

  const [toast, setToast] = useState<ToastState>({
    show: false,
    message: "",
    type: "success",
  });

  const showToast = (message: string, type: "success" | "error") => {
    setToast({ show: true, message, type });
    setTimeout(
      () => setToast({ show: false, message: "", type: "success" }),
      3000
    );
  };

  // Fetch library item by ID and set assetId from its URL
  useEffect(() => {
    const loadItem = async () => {
      const id = String(params?.id || "");
      if (!id) return;

      try {
        const fetched = await libraryService.getLibraryItem(id);
        if (fetched) {
          setItem(fetched);
          setPostText(fetched.caption || "");

          // Extract assetId from imageUrl or videoUrl
          const url = fetched.imageUrl || fetched.videoUrl || "";
          if (url) {
            const parts = url.split("/");
            const filename = parts[parts.length - 1];
            const derivedId = filename.split(".")[0];
            setAssetId(derivedId);
          }

          // Type guard for platforms
          const isPlatform = (p: string): p is (typeof PLATFORMS)[number] => {
            return PLATFORMS.includes(p as (typeof PLATFORMS)[number]);
          };

          // Default platform to item's platform if valid
          if (fetched.platform && isPlatform(fetched.platform)) {
            setPlatform(fetched.platform);
          }
        }
      } catch (error) {
        console.error("Failed to fetch library item:", error);
      }
    };

    loadItem();
  }, [params]);

  const [schedulePost, { isLoading }] = useSchedulePostMutation();

  const getErrorMessage = (err: unknown): string => {
    if (typeof err === "string") return err;
    if (err && typeof err === "object") {
      const obj = err as Record<string, unknown>;
      const data = obj["data"] as Record<string, unknown> | undefined;
      if (data) {
        const detail = data["detail"] as unknown;
        if (Array.isArray(detail) && detail.length) {
          const first = detail[0] as Record<string, unknown>;
          const msg =
            first && typeof first["msg"] === "string"
              ? first["msg"]
              : undefined;
          if (msg) return msg;
        }
        const message = data["message"];
        if (typeof message === "string") return message;
      }
      const message = obj["message"];
      if (typeof message === "string") return message;
    }
    return "Failed to schedule post.";
  };

  const validate = (): string | null => {
    if (!assetId) return "Missing asset ID.";
    if (!postText.trim()) return "Post text is required.";
    return null;
  };

  const handleSubmit = async (immediate: boolean) => {
    const error = validate();
    if (error) {
      showToast(error, "error");
      return;
    }
    if (!immediate && !runAt) {
      showToast("Please select a schedule time or use Post Now.", "error");
      return;
    }

    try {
      const targetRunAt = immediate
        ? undefined
        : runAt
        ? new Date(runAt).toISOString()
        : undefined;

      await schedulePost({
        asset_id: assetId,
        platforms: [platform],
        post_text: postText.trim(),
        run_at: targetRunAt,
      }).unwrap();

      showToast(
        immediate
          ? "Post published successfully!"
          : "Post scheduled successfully!",
        "success"
      );

      setTimeout(() => router.push("/library"), 1000);
    } catch (e: unknown) {
      const apiMsg = getErrorMessage(e);
      showToast(apiMsg, "error");
    }
  };

  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-8 max-w-3xl">
        <div className="mb-4">
          <Button variant="outline" onClick={() => router.push("/library")}>
            Back to Library
          </Button>
        </div>
        <Card className="bg-[#D9D9D9]/[0.72]">
          <CardHeader>
            <CardTitle className="text-xl">Post or Schedule</CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            {item && (
              <div className="flex gap-4 p-4 border rounded-lg bg-muted/50">
                <div className="w-20 h-20 rounded-lg overflow-hidden flex-shrink-0">
                  <img
                    src={item.imageUrl || "/placeholder.svg"}
                    alt={item.title}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-semibold mb-1 line-clamp-2">
                    {item.title}
                  </p>
                  <p className="text-xs text-muted-foreground line-clamp-2">
                    {item.caption}
                  </p>
                </div>
              </div>
            )}

            <div className="space-y-2">
              <Label htmlFor="platform">Platform</Label>
              <select
                id="platform"
                value={platform}
                onChange={(e) =>
                  setPlatform(e.target.value as (typeof PLATFORMS)[number])
                }
                className="w-full rounded-md border border-gray-300 bg-white p-2.5 text-sm outline-none focus:ring-2 focus:ring-black"
              >
                {PLATFORMS.map((p) => (
                  <option key={p} value={p}>
                    {p.charAt(0).toUpperCase() + p.slice(1)}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="postText">Post Text</Label>
              <textarea
                id="postText"
                value={postText}
                onChange={(e) => setPostText(e.target.value)}
                className="w-full min-h-[120px] rounded-md border border-gray-300 bg-white p-3 text-sm outline-none focus:ring-2 focus:ring-black"
                placeholder="Write your post..."
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="runAt">Schedule Time (optional)</Label>
              <input
                id="runAt"
                type="datetime-local"
                value={runAt}
                onChange={(e) => setRunAt(e.target.value)}
                className="w-full rounded-md border border-gray-300 bg-white p-2.5 text-sm outline-none focus:ring-2 focus:ring-black"
              />
              <p className="text-xs text-muted-foreground">
                Leave empty to post immediately using Post Now.
              </p>
            </div>

            <div className="flex gap-3 pt-2">
              <Button
                onClick={() => handleSubmit(false)}
                disabled={isLoading}
                className="flex-1"
              >
                Schedule Post
              </Button>
              <Button
                onClick={() => handleSubmit(true)}
                disabled={isLoading}
                variant="outline"
                className="flex-1"
              >
                Post Now
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>

      <Toast toast={toast} />
    </div>
  );
}

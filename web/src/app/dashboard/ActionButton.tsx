// "use client";

// import { Button } from "@/components/button";
// import { RotateCcw, Download, Clock, ImageIcon } from "lucide-react";
// import { v4 as uuidv4 } from "uuid";
// import { useRouter } from "next/navigation";
// import { StoryboardShot } from "@/lib/types/api";

// interface ActionsProps {
//   generatedContent: {
//     caption: string;
//     hashtags: string[];
//     imageUrl?: string;
//     videoUrl?: string;
//     taskId: string;
//     storyboard?: StoryboardShot[];
//     overlays?: { text: string; position?: string }[];
//   };
//   platform: string;
//   contentType: string;
//   t: Record<string, string>;
//   onRegenerate: () => void;
// }

// export default function Actions({
//   generatedContent,
//   platform,
//   contentType,
//   t,
//   onRegenerate,
// }: ActionsProps) {
//   const router = useRouter();

//   return (
//     <div className="flex flex-wrap gap-3 pt-6 border-t">
//       <Button onClick={onRegenerate} variant="outline">
//         <RotateCcw className="w-4 h-4 mr-2" />
//         {t.regenerate}
//       </Button>

//       <Button variant="secondary">
//         <Download className="w-4 h-4 mr-2" />
//         {t.export}
//       </Button>

//       {/* Schedule */}
//       <Button
//         variant="outline"
//         onClick={() => {
//           const id = uuidv4();
//           localStorage.setItem(
//             "schedulerContent",
//             JSON.stringify({
//               id,
//               caption: generatedContent.caption,
//               hashtags: generatedContent.hashtags,
//               imageUrl: generatedContent.imageUrl,
//               videoUrl: generatedContent.videoUrl,
//               platform,
//               contentType,
//               title: generatedContent.caption.split(" ").slice(0, 6).join(" "),
//             })
//           );
//           router.push(`/scheduler/${id}`);
//         }}
//       >
//         <Clock className="w-4 h-4 mr-2" />
//         {t.schedule}
//       </Button>

//       <Button
//         variant="outline"
//         onClick={() => {
//           try {
//             const libraryContent = localStorage.getItem("libraryContent");
//             const existingLibrary = libraryContent
//               ? JSON.parse(libraryContent)
//               : [];

//             const newContent = {
//               id: uuidv4(),
//               caption: generatedContent.caption,
//               hashtags: generatedContent.hashtags,
//               imageUrl: generatedContent.imageUrl,
//               videoUrl: generatedContent.videoUrl,
//               platform,
//               contentType,
//               title: generatedContent.caption.split(" ").slice(0, 6).join(" "),
//               createdAt: new Date().toISOString(),
//               ...(contentType === "video" && {
//                 storyboard: generatedContent.storyboard,
//                 overlays: generatedContent.overlays,
//               }),
//             };

//             localStorage.setItem(
//               "libraryContent",
//               JSON.stringify([...existingLibrary, newContent])
//             );

//             alert("Content saved to library successfully!");
//           } catch (error) {
//             console.error("Failed to save to library:", error);
//             alert("Failed to save content to library. Please try again.");
//           }
//         }}
//       >
//         <ImageIcon className="w-4 h-4 mr-2" />
//         {t.contentLibrary}
//       </Button>

//       {contentType === "image" && (
//         <>
//           <Button
//             variant="outline"
//             onClick={() => {
//               const id = uuidv4();
//               const newContent = {
//                 id,
//                 caption: generatedContent.caption,
//                 hashtags: generatedContent.hashtags,
//                 imageUrl: generatedContent.imageUrl,
//                 videoUrl: generatedContent.videoUrl,
//                 platform,
//                 contentType,
//                 title: generatedContent.caption
//                   .split(" ")
//                   .slice(0, 6)
//                   .join(" "),
//                 createdAt: new Date().toISOString(),
//               };

//               const libraryContent = localStorage.getItem("libraryContent");
//               const existingLibrary = libraryContent
//                 ? JSON.parse(libraryContent)
//                 : [];
//               localStorage.setItem(
//                 "libraryContent",
//                 JSON.stringify([...existingLibrary, newContent])
//               );

//               router.push(`/post/${id}`);
//             }}
//           >
//             <ImageIcon className="w-4 h-4 mr-2" />
//             {t.post}
//           </Button>

//           <Button
//             variant="outline"
//             onClick={() => {
//               const id = uuidv4();
//               const newContent = {
//                 id,
//                 caption: generatedContent.caption,
//                 hashtags: generatedContent.hashtags,
//                 imageUrl: generatedContent.imageUrl,
//                 videoUrl: generatedContent.videoUrl,
//                 platform,
//                 contentType,
//                 title: generatedContent.caption
//                   .split(" ")
//                   .slice(0, 6)
//                   .join(" "),
//                 createdAt: new Date().toISOString(),
//               };

//               const libraryContent = localStorage.getItem("libraryContent");
//               const existingLibrary = libraryContent
//                 ? JSON.parse(libraryContent)
//                 : [];
//               localStorage.setItem(
//                 "libraryContent",
//                 JSON.stringify([...existingLibrary, newContent])
//               );

//               router.push(`/editor/${id}`);
//             }}
//           >
//             <ImageIcon className="w-4 h-4 mr-2" />
//             {t.edit}
//           </Button>
//         </>
//       )}
//     </div>
//   );
// }
"use client";

import { Button } from "@/components/button";
import { RotateCcw, Download, Clock, ImageIcon } from "lucide-react";
import { useRouter } from "next/navigation";
import { StoryboardShot } from "@/lib/types/api";
import { useState } from "react";
import { contentStorage } from "@/lib/utils/contentStorage"; // Create this utility
import { useExportDraftMutation } from "@/lib/redux/services/api";

interface ActionsProps {
  generatedContent: {
    caption: string;
    hashtags: string[];
    imageUrl?: string;
    videoUrl?: string;
    taskId: string;
    storyboard?: StoryboardShot[];
    overlays?: { text: string; position?: string }[];
  };
  platform: string;
  contentType: string;
  t: Record<string, string>;
  onRegenerate: () => void;
}

export default function Actions({
  generatedContent,
  platform,
  contentType,
  t,
  onRegenerate,
}: ActionsProps) {
  const router = useRouter();
  const [isExporting, setIsExporting] = useState(false);
  const [exportContent] = useExportDraftMutation();

  const handleExport = async () => {
    setIsExporting(true);
    try {
      // Save content first to get a draft ID
      const contentData = {
        caption: generatedContent.caption,
        hashtags: generatedContent.hashtags,
        imageUrl: generatedContent.imageUrl,
        videoUrl: generatedContent.videoUrl,
        platform,
        contentType,
        title: generatedContent.caption.split(" ").slice(0, 6).join(" "),
        ...(contentType === "video" && {
          storyboard: generatedContent.storyboard,
          overlays: generatedContent.overlays,
        }),
      };

      const draftId = contentStorage.saveContent("exportDraft", contentData);

      // Call export endpoint
      const response = await exportContent({ draft_id: draftId }).unwrap();

      // Download the exported file
      const link = document.createElement("a");
      link.href = response.asset_url;
      link.download = `export-${draftId}.${
        contentType === "image" ? "jpg" : "mp4"
      }`;
      link.click();
    } catch (error) {
      console.error("Export failed:", error);
      alert("Failed to export content. Please try again.");
    } finally {
      setIsExporting(false);
    }
  };

  const handleSaveAndNavigate = (
    route: "scheduler" | "editor" | "post" | "library"
  ) => {
    try {
      const contentData = {
        caption: generatedContent.caption,
        hashtags: generatedContent.hashtags,
        imageUrl: generatedContent.imageUrl,
        videoUrl: generatedContent.videoUrl,
        platform,
        contentType,
        title: generatedContent.caption.split(" ").slice(0, 6).join(" "),
        ...(contentType === "video" && {
          storyboard: generatedContent.storyboard,
          overlays: generatedContent.overlays,
        }),
      };

      let id: string;

      if (route === "library") {
        id = contentStorage.saveToLibrary(contentData);
        alert("Content saved to library successfully!");
      } else {
        id = contentStorage.saveContent(`${route}Content`, contentData);
        router.push(`/${route}/${id}`);
      }
    } catch (error) {
      console.error(`Failed to save for ${route}:`, error);
      alert(`Failed to save content. Please try again.`);
    }
  };

  return (
    <div className="flex flex-wrap gap-3 pt-6 border-t">
      <Button onClick={onRegenerate} variant="outline">
        <RotateCcw className="w-4 h-4 mr-2" />
        {t.regenerate}
      </Button>

      <Button variant="secondary" onClick={handleExport} disabled={isExporting}>
        {isExporting ? (
          <>
            <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin mr-2" />
            Exporting...
          </>
        ) : (
          <>
            <Download className="w-4 h-4 mr-2" />
            {t.export}
          </>
        )}
      </Button>

      <Button
        variant="outline"
        onClick={() => handleSaveAndNavigate("scheduler")}
      >
        <Clock className="w-4 h-4 mr-2" />
        {t.schedule}
      </Button>

      <Button
        variant="outline"
        onClick={() => handleSaveAndNavigate("library")}
      >
        <ImageIcon className="w-4 h-4 mr-2" />
        {t.contentLibrary}
      </Button>

      {contentType === "image" && (
        <>
          <Button
            variant="outline"
            onClick={() => handleSaveAndNavigate("post")}
          >
            <ImageIcon className="w-4 h-4 mr-2" />
            {t.post}
          </Button>
          <Button
            variant="outline"
            onClick={() => handleSaveAndNavigate("editor")}
          >
            <ImageIcon className="w-4 h-4 mr-2" />
            {t.edit}
          </Button>
        </>
      )}
    </div>
  );
}

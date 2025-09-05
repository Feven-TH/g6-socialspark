// "use client";
// import { Button } from "@/components/button";
// import { RotateCcw, Download, Clock, ImageIcon } from "lucide-react";
// import { useRouter } from "next/navigation";
// import { StoryboardShot } from "@/lib/types/api";
// import { useState } from "react";
// import { contentStorage } from "@/lib/utils/contentStorage";
// import { TitlePromptModal } from "./TitleModal";

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
//   const [isExporting, setIsExporting] = useState(false);
//   const [showTitleModal, setShowTitleModal] = useState(false);
//   const [savingRoute, setSavingRoute] = useState<
//     "scheduler" | "editor" | "post" | "library"
//   >("library");

//   const handleExport = async () => {
//     setIsExporting(true);
//     // try {
//     //   if (contentType === "image" && generatedContent.imageUrl) {
//     //     await exportAsImage(generatedContent.imageUrl);
//     //   } else if (contentType === "video") {
//     //     await exportAsText();
//     //   } else {
//     //     await exportAsText();
//     //   }
//     // } catch (error) {
//     //   console.error("Export failed:", error);
//     //   alert("Failed to export content. Please try again.");
//     // } finally {
//     //   setIsExporting(false);
//     // }
//   };

//   const exportAsImage = async (imageUrl: string) => {
//     try {
//       const response = await fetch(imageUrl);
//       const blob = await response.blob();

//       const url = URL.createObjectURL(blob);
//       const link = document.createElement("a");
//       link.href = url;

//       const fileName = generatedContent.caption
//         ? `${generatedContent.caption.split(" ").slice(0, 6).join("_")}.png`
//         : `social_content_${Date.now()}.png`;

//       link.download = fileName;
//       document.body.appendChild(link);
//       link.click();
//       document.body.removeChild(link);

//       URL.revokeObjectURL(url);
//     } catch (error) {
//       console.error("Image export error:", error);
//       throw new Error("Failed to export image");
//     }
//   };

//   //   const exportAsText = async () => {
//   //     const content = `
//   // SOCIAL MEDIA CONTENT
//   // ====================
//   // Platform: ${platform}
//   // Type: ${contentType}
//   // Date: ${new Date().toLocaleString()}

//   // CAPTION:
//   // ${generatedContent.caption}

//   // HASHTAGS:
//   // ${generatedContent.hashtags.join(" ")}

//   // ${
//   //   contentType === "video" && generatedContent.storyboard
//   //     ? `
//   // STORYBOARD:
//   // ${generatedContent.storyboard
//   //   .map(
//   //     (shot, index) => `
//   // Shot ${index + 1}:
//   // - ${shot.text}
//   // ${shot.visualDescription ? `- Visual: ${shot.visualDescription}` : ""}
//   // ${shot.duration ? `- Duration: ${shot.duration}s` : ""}
//   // `
//   //   )
//   //   .join("\n")}
//   // `
//   //     : ""
//   // }
//   //     `.trim();

//   //     const blob = new Blob([content], { type: "text/plain" });
//   //     const url = URL.createObjectURL(blob);

//   //     const link = document.createElement("a");
//   //     link.download = `content_${Date.now()}.txt`;
//   //     link.href = url;
//   //     link.click();

//   //     setTimeout(() => URL.revokeObjectURL(url), 100);
//   //   };

//   const handleSaveWithTitle = (
//     title: string,
//     route: "scheduler" | "editor" | "post" | "library"
//   ) => {
//     try {
//       const contentData = {
//         caption: generatedContent.caption,
//         hashtags: generatedContent.hashtags,
//         imageUrl: generatedContent.imageUrl,
//         videoUrl: generatedContent.videoUrl,
//         platform,
//         contentType,
//         title: title.trim(),
//         ...(contentType === "video" && {
//           storyboard: generatedContent.storyboard,
//           overlays: generatedContent.overlays,
//         }),
//       };

//       let id: string;

//       if (route === "library") {
//         id = contentStorage.saveToLibrary(contentData);
//         alert("Content saved to library successfully!");
//       } else {
//         id = contentStorage.saveContent(`${route}Content`, contentData);
//         router.push(`/${route}/${id}`);
//       }
//     } catch (error) {
//       console.error(`Failed to save for ${route}:`, error);
//       alert(`Failed to save content. Please try again.`);
//     }
//   };

//   const handleSaveAndNavigate = (
//     route: "scheduler" | "editor" | "post" | "library"
//   ) => {
//     const defaultTitle = generatedContent.caption
//       .split(" ")
//       .slice(0, 6)
//       .join(" ");

//     if (route === "library") {
//       setSavingRoute(route);
//       setShowTitleModal(true);
//     } else {
//       handleSaveWithTitle(defaultTitle, route);
//     }
//   };

//   return (
//     <>
//       <div className="flex flex-wrap gap-3 pt-6 border-t">
//         <Button onClick={onRegenerate} variant="outline">
//           <RotateCcw className="w-4 h-4 mr-2" />
//           {t.regenerate}
//         </Button>

//         <Button
//           variant="secondary"
//           onClick={handleExport}
//           disabled={isExporting}
//         >
//           {isExporting ? (
//             <>
//               <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin mr-2" />
//               Exporting...
//             </>
//           ) : (
//             <>
//               <Download className="w-4 h-4 mr-2" />
//               {t.export}
//             </>
//           )}
//         </Button>

//         <Button
//           variant="outline"
//           onClick={() => handleSaveAndNavigate("scheduler")}
//         >
//           <Clock className="w-4 h-4 mr-2" />
//           {t.schedule}
//         </Button>

//         <Button
//           variant="outline"
//           onClick={() => handleSaveAndNavigate("library")}
//         >
//           <ImageIcon className="w-4 h-4 mr-2" />
//           {t.contentLibrary}
//         </Button>

//         {contentType === "image" && (
//           <>
//             <Button
//               variant="outline"
//               onClick={() => handleSaveAndNavigate("post")}
//             >
//               <ImageIcon className="w-4 h-4 mr-2" />
//               {t.post}
//             </Button>
//             <Button
//               variant="outline"
//               onClick={() => handleSaveAndNavigate("editor")}
//             >
//               <ImageIcon className="w-4 h-4 mr-2" />
//               {t.edit}
//             </Button>
//           </>
//         )}
//       </div>

//       <TitlePromptModal
//         isOpen={showTitleModal}
//         onClose={() => setShowTitleModal(false)}
//         onSave={(title) => handleSaveWithTitle(title, savingRoute)}
//         defaultTitle={generatedContent.caption.split(" ").slice(0, 6).join(" ")}
//       />
//     </>
//   );
// }
"use client";
import { Button } from "@/components/button";
import { RotateCcw, Download, Clock, ImageIcon } from "lucide-react";
import { useRouter } from "next/navigation";
import { StoryboardShot } from "@/lib/types/api";
import { useState } from "react";
import { contentStorage } from "@/lib/utils/contentStorage";
import { TitlePromptModal } from "./TitleModal";

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
  const [showTitleModal, setShowTitleModal] = useState(false);
  const [savingRoute, setSavingRoute] = useState<
    "scheduler" | "editor" | "post" | "library"
  >("library");

  const handleExport = async () => {
    setIsExporting(true);
    try {
      if (contentType === "image" && generatedContent.imageUrl) {
        await exportAsImage(generatedContent.imageUrl);
      } else if (contentType === "video" && generatedContent.videoUrl) {
        await exportAsVideo(generatedContent.videoUrl);
      } else {
        await exportAsText();
      }
    } catch (error) {
      console.error("Export failed:", error);
      alert("Failed to export content. Please try again.");
    } finally {
      setIsExporting(false);
    }
  };

  const exportAsImage = async (imageUrl: string) => {
    try {
      const response = await fetch(imageUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch image: ${response.status}`);
      }

      const blob = await response.blob();
      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.href = url;

      const fileName = generatedContent.caption
        ? `${generatedContent.caption.split(" ").slice(0, 6).join("_")}.png`
        : `social_content_${Date.now()}.png`;

      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Clean up
      setTimeout(() => URL.revokeObjectURL(url), 100);
    } catch (error) {
      console.error("Image export error:", error);
      throw new Error("Failed to export image");
    }
  };

  const exportAsVideo = async (videoUrl: string) => {
    try {
      const response = await fetch(videoUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch video: ${response.status}`);
      }

      const blob = await response.blob();
      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.href = url;

      const fileName = generatedContent.caption
        ? `${generatedContent.caption.split(" ").slice(0, 6).join("_")}.mp4`
        : `social_content_${Date.now()}.mp4`;

      link.download = fileName;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);

      // Clean up
      setTimeout(() => URL.revokeObjectURL(url), 100);
    } catch (error) {
      console.error("Video export error:", error);
      throw new Error("Failed to export video");
    }
  };

  const exportAsText = async () => {
    try {
      const content = `
SOCIAL MEDIA CONTENT
====================
Platform: ${platform}
Type: ${contentType}
Date: ${new Date().toLocaleString()}

CAPTION:
${generatedContent.caption}

HASHTAGS:
${generatedContent.hashtags.join(" ")}

${
  contentType === "video" && generatedContent.storyboard
    ? `
STORYBOARD:
${generatedContent.storyboard
  .map(
    (shot, index) => `
Shot ${index + 1}:
- Text: ${shot.text}
- Duration: ${shot.duration}s
`
  )
  .join("\n")}
`
    : ""
}
    `.trim();

      const blob = new Blob([content], { type: "text/plain" });
      const url = URL.createObjectURL(blob);

      const link = document.createElement("a");
      link.download = `content_${Date.now()}.txt`;
      link.href = url;
      link.click();

      // Clean up
      setTimeout(() => URL.revokeObjectURL(url), 100);
    } catch (error) {
      console.error("Text export error:", error);
      throw new Error("Failed to export text");
    }
  };

  const handleSaveWithTitle = (
    title: string,
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
        title: title.trim(),
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

  const handleSaveAndNavigate = (
    route: "scheduler" | "editor" | "post" | "library"
  ) => {
    const defaultTitle = generatedContent.caption
      .split(" ")
      .slice(0, 6)
      .join(" ");

    if (route === "library") {
      setSavingRoute(route);
      setShowTitleModal(true);
    } else {
      handleSaveWithTitle(defaultTitle, route);
    }
  };

  return (
    <>
      <div className="flex flex-wrap gap-3 pt-6 border-t">
        <Button onClick={onRegenerate} variant="outline">
          <RotateCcw className="w-4 h-4 mr-2" />
          {t.regenerate}
        </Button>

        <Button
          variant="secondary"
          onClick={handleExport}
          disabled={isExporting}
        >
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

      <TitlePromptModal
        isOpen={showTitleModal}
        onClose={() => setShowTitleModal(false)}
        onSave={(title) => handleSaveWithTitle(title, savingRoute)}
        defaultTitle={generatedContent.caption.split(" ").slice(0, 6).join(" ")}
      />
    </>
  );
}

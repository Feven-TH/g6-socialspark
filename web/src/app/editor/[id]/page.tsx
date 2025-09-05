"use client";
import { useEffect, useRef, useState } from "react";
import { useRouter, useParams } from "next/navigation";
import Image from "next/image";

import { Button } from "@/components/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/card";
import { Textarea } from "@/components/textarea";
import { Input } from "@/components/input";
import { Label } from "@/components/label";
import { Badge } from "@/components/badge";
import { Slider } from "@/components/slider";
import * as htmlToImage from "html-to-image"; 

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/select";
import {
  Type,
  Layers,
  Download,
  Save,
  Undo,
  Redo,
  AlignLeft,
  AlignCenter,
  Bold,
  Italic,
  Hash,
  Plus,
  X,
  Eye,
  EyeOff,
  Sparkles,
  AlignRight,
} from "lucide-react";

interface Snap {
  id: number;
  title: string;
  caption: string;
  hashtags: string[];
  imageUrl: string;
  videoUrl?: string;
  platform: string;
  type: string;
  textAlign?: "left" | "center" | "right";
  fontSize?: number;
  isBold?: boolean;
  isItalic?: boolean;
  textColor?: string;
  backgroundColor?: string;
  textVisible?: boolean;
  backgroundVisible?: boolean;
}

interface Brand {
  businessName: string;
  businessType: string;
  description: string;
  primaryColor: string;
  secondaryColor: string;
  accentColor: string;
  logoUrl?: string;
  defaultHashtags: string[];
  brandVoice: string;
  targetAudience: string;
}

function getContrastColor(hex: string) {
  const cleanHex = hex.replace("#", "");
  const r = parseInt(cleanHex.substring(0, 2), 16);
  const g = parseInt(cleanHex.substring(2, 4), 16);
  const b = parseInt(cleanHex.substring(4, 6), 16);
  const brightness = (r * 299 + g * 587 + b * 114) / 1000;
  return brightness > 150 ? "#000000" : "#ffffff";
}

export default function EditorPage() {

  const { id } = useParams();
   const previewRef = useRef<HTMLDivElement>(null);

  const [caption, setCaption] = useState("");
  const [hashtags, setHashtags] = useState<string[]>([]);
  const [newHashtag, setNewHashtag] = useState("");
  const [textAlign, setTextAlign] = useState<"left" | "center" | "right">(
    "left"
  );
  const [fontSize, setFontSize] = useState([16]);
  const [isBold, setIsbold] = useState(false);
  const [isItalic, setIsItalic] = useState(false);

  const [textColor, setTextColor] = useState("#000000");
  const [backgroundColor, setBackgroundColor] = useState("#ffffff");
  const [textVisible, setTextVisible] = useState(true);
  const [backgroundVisible, setBackgroundVisible] = useState(true);
  const [imageUrl, setImageUrl] = useState("");

  const [brand, setBrand] = useState<Brand | null>(null);
  const [brandPresets, setBrandPresets] = useState<
    { name: string; color: string }[]
  >([]);

  useEffect(() => {
    if (!id) return;
    const stored = localStorage.getItem("libraryContent");
    if (!stored) return;
    const items: Snap[] = JSON.parse(stored);
    const snap = items.find((item) => item.id.toString() === id);
    if (snap) {
      setCaption(snap.caption);
      setHashtags(snap.hashtags || []);
      setImageUrl(snap.imageUrl);
      if (snap.textAlign) setTextAlign(snap.textAlign);
      if (snap.fontSize) setFontSize([snap.fontSize]);
      if (snap.isBold !== undefined) setIsbold(snap.isBold);
      if (snap.isItalic !== undefined) setIsItalic(snap.isItalic);
      if (snap.textColor) setTextColor(snap.textColor);
      if (snap.backgroundColor) setBackgroundColor(snap.backgroundColor);
      if (snap.textVisible !== undefined) setTextVisible(snap.textVisible);
      if (snap.backgroundVisible !== undefined)
        setBackgroundVisible(snap.backgroundVisible);
    }
  }, [id]);

  useEffect(() => {
    const storedBrand = localStorage.getItem("brandSetting");
    if (!storedBrand) return;
    const parsed = JSON.parse(storedBrand) as Brand;
    setBrand(parsed);

    const presets = [
      parsed.primaryColor && { name: "Primary", color: parsed.primaryColor },
      parsed.secondaryColor && {
        name: "Secondary",
        color: parsed.secondaryColor,
      },
      parsed.accentColor && { name: "Accent", color: parsed.accentColor },
    ].filter(Boolean) as { name: string; color: string }[];
    setBrandPresets(presets);

    if (parsed.defaultHashtags?.length && hashtags.length === 0) {
      setHashtags(parsed.defaultHashtags);
    }

    if (textColor === "#000000" && parsed.primaryColor) {
      setTextColor(parsed.primaryColor);
    }
  }, []);

  const addHashtag = () => {
    if (
      newHashtag.trim() &&
      !hashtags.includes(newHashtag.trim()) &&
      hashtags.length < 30
    ) {
      setHashtags([...hashtags, newHashtag.trim()]);
      setNewHashtag("");
    }
  };

  const removeHashtag = (hashtag: string) => {
    setHashtags(hashtags.filter((h) => h !== hashtag));
  };

  const saveDraft = () => {
    const stored = localStorage.getItem("libraryContent");
    if (!stored) return;
    const items: Snap[] = JSON.parse(stored);
    const index = items.findIndex((item) => item.id.toString() === id);
    if (index !== -1) {
      items[index] = {
        ...items[index],
        caption,
        hashtags,
        imageUrl,
        textAlign,
        fontSize: fontSize[0],
        isBold,
        isItalic,
        textColor,
        backgroundColor,
        textVisible,
        backgroundVisible,
      };
      localStorage.setItem("libraryContent", JSON.stringify(items));
      alert("Draft saved!");
      window.location.href = "/library";
    } else {
      alert("Could not find this snap in library!");
    }
  };

  const handleDownload = async () => {
    if (!previewRef.current) return;

    try {
      const dataUrl = await htmlToImage.toPng(previewRef.current, {
        cacheBust: true,
        quality: 1,
      });

      const link = document.createElement("a");
      link.download = `snap-${id || "export"}.png`;
      link.href = dataUrl;
      link.click();
    } catch (err) {
      console.error("Export failed", err);
      alert("Failed to export image, please try again.");
    }
  };


  return (
    <div className="min-h-screen bg-gray-50">
      <main className="max-w-6xl mx-auto bg-white">
        <header className="bg-white px-6 pt-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-gray-900 rounded-lg flex items-center justify-center">
                <Sparkles className="w-5 h-5 text-white" />
              </div>
              <div>
                <h1 className="font-semibold text-gray-900">Content Library</h1>
                <p className="text-sm text-gray-500">Fine-tune your content</p>
              </div>
            </div>
            <nav className="flex items-center gap-8">
              <a href="/dashboard" className="text-gray-900 font-medium">
                DashBoard
              </a>
              <a href="/brand" className="text-gray-600 hover:text-gray-900">
                Brand
              </a>
              <a href="/library" className="text-gray-600 hover:text-gray-900">
                Library
              </a>
              <div className="flex items-center gap-2 text-gray-600">
                <Type className="w-4 h-4" />
                <span className="text-sm">EN</span>
              </div>
            </nav>
          </div>
          <div className="flex items-center justify-end gap-4 mt-4">
            <Button variant="ghost" size="sm">
              <Undo className="w-4 h-4" />
            </Button>
            <Button variant="ghost" size="sm">
              <Redo className="w-4 h-4" />
            </Button>
            <Button variant="outline" size="sm" onClick={saveDraft}>
              <Save className="w-4 h-4 mr-2" /> save draft
            </Button>
          </div>
        </header>
        <div className="md:grid md:grid-cols-3 px-8 mx-auto">
          <div className="md:col-span-2 p-2 py-5">
            <Card className="bg-gray-100 overflow-hidden py-4 gap-2">
              <CardHeader className="flex items-center gap-2">
                <div className="w-3 h-3 bg-gray-300 rounded flex items-center justify-center">
                  <Eye className="w-3 h-3 text-gray-600" />
                </div>
                <CardTitle className="font-semibold">Visual Preview</CardTitle>
              </CardHeader>
              <CardContent>
                <div
                  ref={previewRef}
                  className="origin-top mx-auto aspect-square rounded-lg overflow-hidden relative"
                  style={{
                    backgroundColor: backgroundColor
                      ? backgroundColor
                      : "#ffffff",
                  }}
                >
                  {backgroundVisible && imageUrl && (
                    <Image
                      src={imageUrl}
                      alt="Preview"
                      width={300}
                      height={300}
                      className="w-full h-full object-cover"
                    />
                  )}

                  {textVisible && (
                    <div className="absolute bottom-4 left-4 right-4">
                      <div
                        className="backdrop-blur-sm rounded-lg p-4"
                        style={{ backgroundColor: `${backgroundColor}cc` }}
                      >
                        <p
                          className="font-medium mb-2"
                          style={{
                            fontWeight: isBold ? "bold" : "",
                            fontStyle: isItalic ? "italic" : "",
                            textAlign,
                            fontSize: `${fontSize[0]}px`,
                            color: textColor,
                          }}
                        >
                          {caption}
                        </p>
                        <div
                          className="flex flex-wrap gap-1 text-sm"
                          style={{ color: textColor }}
                        >
                          {hashtags.map((hashtag, index) => (
                            <span key={index}>#{hashtag}</span>
                          ))}
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>

            {/* Caption Section */}
            <div className="bg-white mt-8 ">
              <div className="max-w-4xl mx-auto space-y-4">
                <div className="bg-gray-100 rounded-lg p-4 shadow">
                  <div className="flex items-center mb-2">
                    <span className="font-semibold ml-4">Caption</span>
                  </div>
                  <div className="flex items-center gap-2 mb-2">
                    <Button variant="ghost" size="sm">
                      <Type className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setTextAlign("left")}
                      className={textAlign === "left" ? "bg-muted" : ""}
                    >
                      <AlignLeft className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setTextAlign("center")}
                      className={textAlign === "center" ? "bg-muted" : ""}
                    >
                      <AlignCenter className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setTextAlign("right")}
                      className={textAlign === "right" ? "bg-muted" : ""}
                    >
                      <AlignRight className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsbold(!isBold)}
                      className={isBold ? "bg-muted" : ""}
                    >
                      <Bold className="w-4 h-4" />
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsItalic(!isItalic)}
                      className={isItalic ? "bg-muted" : ""}
                    >
                      <Italic className="w-4 h-4" />
                    </Button>
                  </div>
                  <Textarea
                    value={caption}
                    onChange={(e) => setCaption(e.target.value)}
                    className="min-h-[80px] resize-none bg-gray-100"
                    placeholder="Write your caption here..."
                  />
                  <div className="text-right text-sm text-gray-500 mt-1">
                    {caption.length}/2200 characters
                  </div>
                </div>

                {/* Hashtags Section */}
                <div className="bg-gray-100 rounded-xl p-5">
                  <div className="flex items-center gap-2 mb-4">
                    <Hash className="w-5 h-5" />
                    <span className="font-semibold">Hashtags</span>
                  </div>
                  <div className="flex items-center gap-2 mb-4">
                    <Input
                      placeholder="Add hashtag"
                      value={newHashtag}
                      onChange={(e) => setNewHashtag(e.target.value)}
                      onKeyPress={(e) => e.key === "Enter" && addHashtag()}
                      className="flex-1"
                    />
                    <Button
                      onClick={addHashtag}
                      className="bg-blue-900 text-white hover:bg-blue-800"
                    >
                      <Plus className="w-4 h-4" />
                    </Button>
                  </div>
                  <div className="flex flex-wrap gap-2 mb-2">
                    {hashtags.map((hashtag, index) => (
                      <Badge
                        key={index}
                        className="bg-orange-500 text-white hover:bg-orange-600 flex items-center gap-1"
                      >
                        #{hashtag}
                        <button
                          onClick={() => removeHashtag(hashtag)}
                          className="ml-1 hover:text-gray-200"
                        >
                          <X className="w-3 h-3" />
                        </button>
                      </Badge>
                    ))}
                  </div>
                  <div className="text-sm text-gray-500">
                    {hashtags.length}/30 hashtags
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Sidebar */}
          <div className="md:col-span-1 bg-white p-4 space-y-4 overflow-y-auto w-full">
            {/* Text Style Panel */}
            <Card className="bg-gray-100 gap-6 py-3">
              <CardContent className="p-4 space-y-2">
                <div className="flex items-center gap-2 mb-4">
                  <Type className="w-5 h-5" />
                  <span className="font-semibold">Text Style</span>
                </div>
                <div>
                  <Label className="text-sm font-medium">Font Size</Label>
                  <div className="mt-2">
                    <div className="w-full h-2 bg-black rounded-full mb-2"></div>
                    <span className="text-sm">{fontSize[0]}px</span>
                  </div>
                  <Slider
                    min={12}
                    max={32}
                    step={1}
                    value={fontSize}
                    onValueChange={setFontSize}
                    className="mt-2"
                  />
                </div>
                <div>
                  <Label className="text-sm font-medium">Text Color</Label>
                  <div className="flex items-center gap-3 mt-2">
                    <div
                      className="w-8 h-8 rounded border"
                      style={{ backgroundColor: textColor }}
                    ></div>
                    <Input
                      type="text"
                      value={textColor}
                      onChange={(e) => setTextColor(e.target.value)}
                      className="flex-1"
                    />
                  </div>
                </div>
                <div>
                  <Label className="text-sm font-medium">
                    Background overlay
                  </Label>
                  <div className="flex items-center gap-3 mt-2">
                    <div
                      className="w-8 h-8 rounded border"
                      style={{ backgroundColor: backgroundColor }}
                    ></div>
                    <Input
                      type="text"
                      value={backgroundColor}
                      onChange={(e) => setBackgroundColor(e.target.value)}
                      className="flex-1"
                    />
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Brand Presets Panel */}
            <Card className="bg-gray-200 gap-2 py-3">
              <CardContent className="p-4">
                <div className="flex items-center gap-2 mb-4">
                  <Sparkles className="w-5 h-5" />
                  <span className="font-semibold">Brand Presets</span>
                </div>
                <div className="flex gap-3">
                  {brandPresets.length > 0 ? (
                    brandPresets.map((preset, index) => (
                      <div
                        key={index}
                        className="w-12 h-6 rounded cursor-pointer border border-gray-300"
                        style={{ backgroundColor: preset.color }}
                        onClick={() => {
                          setBackgroundColor(preset.color);
                          setTextColor(getContrastColor(preset.color));
                        }}
                        title={preset.name}
                      ></div>
                    ))
                  ) : (
                    <span className="text-sm text-gray-500">
                      No brand colors set
                    </span>
                  )}
                </div>
              </CardContent>
            </Card>

            {/* Layers Panel */}
            <Card className="bg-gray-200 gap-2 py-3">
              <CardContent className="p-4">
                <div className="flex items-center gap-2 mb-4">
                  <Layers className="w-5 h-5" />
                  <span className="font-semibold">Layers</span>
                </div>
                <div className="space-y-2">
                  <div className="flex items-center justify-between ">
                    <span className="text-sm">text overlay</span>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setTextVisible(!textVisible)}
                    >
                      {textVisible ? (
                        <Eye className="w-4 h-4" />
                      ) : (
                        <EyeOff className="w-4 h-4" />
                      )}
                    </Button>
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-sm">Background image</span>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setBackgroundVisible(!backgroundVisible)}
                    >
                      {backgroundVisible ? (
                        <Eye className="w-4 h-4" />
                      ) : (
                        <EyeOff className="w-4 h-4" />
                      )}
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Export Panel */}
            <Card className="bg-gray-200  gap-2 py-3">
              <CardContent className="p-3">
                <h3 className="font-semibold text-[16px] mb-2">Export</h3>
                <Select defaultValue="instagram">
                  <SelectTrigger className="mb-2">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="instagram">
                      Instagram post(1:1)
                    </SelectItem>
                    <SelectItem value="tiktok">Tiktok post</SelectItem>
                  </SelectContent>
                </Select>
                <Button className="w-full bg-black text-white hover:bg-gray-800" onClick={handleDownload}> 
                  <Download className="w-4 h-4 mr-2" />
                  Download
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </main>

      {/* <Footer/> */}
    </div>
  );
}

"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import { Button } from "@/app/components/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/app/components/card"
import { Textarea } from "@/app/components/textarea"
import { Input } from "@/app/components/input"
import { Label } from "@/app/components/label"
import { Badge } from "@/app/components/badge"
import { Slider } from "@/app/components/slider"
import Header from "@/app/components/header"
import Footer from "@/app/components/footer"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/app/components/select"
import {
  Sparkles,
  Type,
  Palette,
  ImageIcon,
  Layers,
  Download,
  Share2,
  Save,
  Undo,
  Redo,
  AlignLeft,
  AlignCenter,
  AlignRight,
  Bold,
  Italic,
  Hash,
  Plus,
  X,
  Eye,
} from "lucide-react"

export default function EditorPage() {
  const router = useRouter()
  const [caption, setCaption] = useState(
    "Try our new Caramel Macadamia Latte! Perfect coffee blend with sweet caramel and creamy macadamia. Come today and experience the unique taste! ☕✨",
  )
  const [hashtags, setHashtags] = useState(["AddisAbebaCafe", "EthiopianCoffee", "Latte", "Caramel", "Macadamia"])
  const [newHashtag, setNewHashtag] = useState("")
  const [textAlign, setTextAlign] = useState("left")
  const [fontSize, setFontSize] = useState([16])
  const [textColor, setTextColor] = useState("#000000")
  const [backgroundColor, setBackgroundColor] = useState("#ffffff")

  const addHashtag = () => {
    if (newHashtag.trim() && !hashtags.includes(newHashtag.trim())) {
      setHashtags([...hashtags, newHashtag.trim()])
      setNewHashtag("")
    }
  }

  const removeHashtag = (index: number) => {
    setHashtags(hashtags.filter((_, i) => i !== index))
  }

  const handleSchedule = () => {
    const contentData = {
      caption,
      hashtags,
      textAlign,
      fontSize: fontSize[0],
      textColor,
      backgroundColor,
      image: "/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png",
      timestamp: Date.now(),
    }
    localStorage.setItem("editorContent", JSON.stringify(contentData))
    router.push("/scheduler")
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header/>
      {/* Header */}
      <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                <Sparkles className="w-6 h-6 text-primary-foreground" />
              </div>
              <div>
                <h1 className="text-xl font-black font-montserrat text-foreground">Content Editor</h1>
                <p className="text-sm text-muted-foreground">Fine-tune your content</p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <Button variant="outline" size="sm">
                <Undo className="w-4 h-4" />
              </Button>
              <Button variant="outline" size="sm">
                <Redo className="w-4 h-4" />
              </Button>
              <Button variant="outline" size="sm">
                <Save className="w-4 h-4 mr-2" />
                Save Draft
              </Button>
              
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 flex-1">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Editor Panel */}
          <div className="lg:col-span-2 space-y-6">
            {/* Visual Preview */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <ImageIcon className="w-5 h-5" />
                  Visual Preview
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="aspect-square bg-muted rounded-lg overflow-hidden relative">
                  <img
                    src="/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png"
                    alt="Content preview"
                    className="w-full h-full object-cover"
                  />
                  <div
                    className="absolute inset-0 flex items-end p-6"
                    style={{ backgroundColor: `${backgroundColor}20` }}
                  >
                    <div
                      className="bg-white/90 backdrop-blur-sm rounded-lg p-4 w-full"
                      style={{
                        textAlign: textAlign as any,
                        fontSize: `${fontSize[0]}px`,
                        color: textColor,
                      }}
                    >
                      <p className="font-medium mb-2">{caption}</p>
                      <div className="flex flex-wrap gap-1">
                        {hashtags.slice(0, 5).map((hashtag, index) => (
                          <span key={index} className="text-blue-600 text-sm">
                            #{hashtag}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Caption Editor */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Type className="w-5 h-5" />
                  Caption
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center gap-2 mb-4">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setTextAlign("left")}
                    className={textAlign === "left" ? "bg-muted" : ""}
                  >
                    <AlignLeft className="w-4 h-4" />
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setTextAlign("center")}
                    className={textAlign === "center" ? "bg-muted" : ""}
                  >
                    <AlignCenter className="w-4 h-4" />
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setTextAlign("right")}
                    className={textAlign === "right" ? "bg-muted" : ""}
                  >
                    <AlignRight className="w-4 h-4" />
                  </Button>
                  <div className="w-px h-6 bg-border mx-2" />
                  <Button variant="outline" size="sm">
                    <Bold className="w-4 h-4" />
                  </Button>
                  <Button variant="outline" size="sm">
                    <Italic className="w-4 h-4" />
                  </Button>
                </div>

                <Textarea
                  value={caption}
                  onChange={(e) => setCaption(e.target.value)}
                  className="min-h-[120px] text-base"
                  placeholder="Write your caption..."
                />

                <div className="text-sm text-muted-foreground">{caption.length}/2200 characters</div>
              </CardContent>
            </Card>

            {/* Hashtags Editor */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Hash className="w-5 h-5" />
                  Hashtags
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex gap-2">
                  <Input
                    placeholder="Add hashtag"
                    value={newHashtag}
                    onChange={(e) => setNewHashtag(e.target.value)}
                    onKeyPress={(e) => e.key === "Enter" && addHashtag()}
                  />
                  <Button onClick={addHashtag}>
                    <Plus className="w-4 h-4" />
                  </Button>
                </div>

                <div className="flex flex-wrap gap-2">
                  {hashtags.map((hashtag, index) => (
                    <Badge key={index} variant="secondary" className="flex items-center gap-1">
                      #{hashtag}
                      <Button
                        variant="ghost"
                        size="sm"
                        className="h-4 w-4 p-0 hover:bg-destructive hover:text-destructive-foreground"
                        onClick={() => removeHashtag(index)}
                      >
                        <X className="w-3 h-3" />
                      </Button>
                    </Badge>
                  ))}
                </div>

                <div className="text-sm text-muted-foreground">{hashtags.length}/30 hashtags</div>
              </CardContent>
            </Card>
          </div>

          {/* Styling Panel */}
          <div className="space-y-6">
            {/* Text Styling */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Type className="w-5 h-5" />
                  Text Style
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label>Font Size</Label>
                  <Slider value={fontSize} onValueChange={setFontSize} max={24} min={12} step={1} className="w-full" />
                  <div className="text-sm text-muted-foreground">{fontSize[0]}px</div>
                </div>

                <div className="space-y-2">
                  <Label>Text Color</Label>
                  <div className="flex items-center gap-2">
                    <Input
                      type="color"
                      value={textColor}
                      onChange={(e) => setTextColor(e.target.value)}
                      className="w-12 h-10 p-1 border rounded"
                    />
                    <Input value={textColor} onChange={(e) => setTextColor(e.target.value)} className="flex-1" />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>Background Overlay</Label>
                  <div className="flex items-center gap-2">
                    <Input
                      type="color"
                      value={backgroundColor}
                      onChange={(e) => setBackgroundColor(e.target.value)}
                      className="w-12 h-10 p-1 border rounded"
                    />
                    <Input
                      value={backgroundColor}
                      onChange={(e) => setBackgroundColor(e.target.value)}
                      className="flex-1"
                    />
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Brand Presets */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Palette className="w-5 h-5" />
                  Brand Presets
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-3 gap-2">
                  <Button
                    variant="outline"
                    className="h-12 p-2 bg-transparent"
                    onClick={() => {
                      setTextColor("#003366")
                      setBackgroundColor("#f9c51c")
                    }}
                  >
                    <div className="w-full h-full bg-gradient-to-r from-[#003366] to-[#f9c51c] rounded"></div>
                  </Button>
                  <Button
                    variant="outline"
                    className="h-12 p-2 bg-transparent"
                    onClick={() => {
                      setTextColor("#ffffff")
                      setBackgroundColor("#003366")
                    }}
                  >
                    <div className="w-full h-full bg-[#003366] rounded"></div>
                  </Button>
                  <Button
                    variant="outline"
                    className="h-12 p-2 bg-transparent"
                    onClick={() => {
                      setTextColor("#003366")
                      setBackgroundColor("#ffffff")
                    }}
                  >
                    <div className="w-full h-full bg-white border rounded"></div>
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Layers */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Layers className="w-5 h-5" />
                  Layers
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                <div className="flex items-center justify-between p-2 bg-muted rounded">
                  <span className="text-sm">Text Overlay</span>
                  <Button variant="ghost" size="sm">
                    <Eye className="w-4 h-4" />
                  </Button>
                </div>
                <div className="flex items-center justify-between p-2 bg-muted rounded">
                  <span className="text-sm">Background Image</span>
                  <Button variant="ghost" size="sm">
                    <Eye className="w-4 h-4" />
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Export Options */}
            <Card>
              <CardHeader>
                <CardTitle>Export</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <Select defaultValue="instagram-post">
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="instagram-post">Instagram Post (1:1)</SelectItem>
                    <SelectItem value="instagram-story">Instagram Story (9:16)</SelectItem>
                    <SelectItem value="tiktok">TikTok (9:16)</SelectItem>
                  </SelectContent>
                </Select>

                <Button className="w-full">
                  <Download className="w-4 h-4 mr-2" />
                  Download
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      {/* Footer */}
      <Footer />
    </div>
  )
}
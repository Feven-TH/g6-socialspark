"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import Image from "next/image"
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
  const [textAlign, setTextAlign] = useState<"left" | "center" | "right">("left")
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
      <Header />

      <main className="flex-1 p-6">
        <div className="max-w-7xl mx-auto space-y-6">
          <div className="flex justify-between items-center">
            <h1 className="text-3xl font-bold">Content Editor</h1>
            <div className="flex gap-2">
              <Button variant="outline" size="sm">
                <Save className="w-4 h-4 mr-2" />
                Save Draft
              </Button>
              <Button size="sm" onClick={handleSchedule}>
                <Download className="w-4 h-4 mr-2" />
                Schedule Post
              </Button>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Create Your Content</CardTitle>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-2">
                  <Label htmlFor="caption">Caption</Label>
                  <Textarea
                    id="caption"
                    value={caption}
                    onChange={(e) => setCaption(e.target.value)}
                    className="min-h-[120px]"
                  />
                </div>

                <div className="space-y-2">
                  <Label>Text Alignment</Label>
                  <div className="flex gap-2">
                    <Button
                      type="button"
                      variant={textAlign === "left" ? "default" : "outline"}
                      size="icon"
                      onClick={() => setTextAlign("left")}
                    >
                      <AlignLeft className="w-4 h-4" />
                    </Button>
                    <Button
                      type="button"
                      variant={textAlign === "center" ? "default" : "outline"}
                      size="icon"
                      onClick={() => setTextAlign("center")}
                    >
                      <AlignCenter className="w-4 h-4" />
                    </Button>
                    <Button
                      type="button"
                      variant={textAlign === "right" ? "default" : "outline"}
                      size="icon"
                      onClick={() => setTextAlign("right")}
                    >
                      <AlignRight className="w-4 h-4" />
                    </Button>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>Font Size</Label>
                  <Slider min={12} max={32} step={1} value={fontSize} onValueChange={setFontSize} />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Text Color</Label>
                    <Input type="color" value={textColor} onChange={(e) => setTextColor(e.target.value)} />
                  </div>
                  <div className="space-y-2">
                    <Label>Background Color</Label>
                    <Input type="color" value={backgroundColor} onChange={(e) => setBackgroundColor(e.target.value)} />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>Hashtags</Label>
                  <div className="flex flex-wrap gap-2">
                    {hashtags.map((hashtag, index) => (
                      <Badge key={index} variant="secondary" className="flex items-center gap-1">
                        #{hashtag}
                        <button onClick={() => removeHashtag(index)} className="ml-1 hover:text-destructive">
                          <X className="w-3 h-3" />
                        </button>
                      </Badge>
                    ))}
                  </div>
                  <div className="flex gap-2">
                    <Input
                      placeholder="Add hashtag"
                      value={newHashtag}
                      onChange={(e) => setNewHashtag(e.target.value)}
                      onKeyPress={(e) => e.key === "Enter" && addHashtag()}
                    />
                    <Button type="button" onClick={addHashtag} variant="outline">
                      <Plus className="w-4 h-4 mr-2" />
                      Add
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Preview</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="aspect-square bg-muted rounded-lg overflow-hidden relative">
                  <Image
                    src="/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png"
                    alt="Content preview"
                    fill
                    className="object-cover"
                  />
                  <div
                    className="absolute inset-0 flex items-end p-6"
                    style={{ backgroundColor: `${backgroundColor}20` }}
                  >
                    <div
                      className="bg-white/90 backdrop-blur-sm rounded-lg p-4 w-full"
                      style={{
                        textAlign,
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
          </div>
        </div>
      </main>

      <Footer />
    </div>
  )
}

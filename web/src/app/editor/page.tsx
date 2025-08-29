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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/app/components/select"
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
} from "lucide-react"

export default function EditorPage() {
  const router = useRouter()
  const [caption, setCaption] = useState(
    "try our new caramel Macadamia Latte !Perfect coffee blend with sweet and creamy macadamia. come today and experience the unique taste",
  )
  const [hashtags, setHashtags] = useState(["AddisAbabaCafe", "EthiopianCoffee", "Latte"])
  const [newHashtag, setNewHashtag] = useState("")
  const [textAlign, setTextAlign] = useState<"left" | "center" | "right">("left")
  const [fontSize, setFontSize] = useState([16])
  const [textColor, setTextColor] = useState("#000000")
  const [backgroundColor, setBackgroundColor] = useState("#ffffff")
  const [textVisible, setTextVisible] = useState(true)
  const [backgroundVisible, setBackgroundVisible] = useState(true)

  const addHashtag = () => {
    if (newHashtag.trim() && !hashtags.includes(newHashtag.trim()) && hashtags.length < 30) {
      setHashtags([...hashtags, newHashtag.trim()])
      setNewHashtag("")
    }
  }

  const removeHashtag = (hashtag: string) => {
    setHashtags(hashtags.filter((h) => h !== hashtag))
  }

  const brandPresets = [
    { name: "Yellow", color: "#F59E0B" },
    { name: "Blue", color: "#1E40AF" },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200 px-6 py-4">
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
            <a href="#" className="text-gray-900 font-medium">
              DashBoard
            </a>
            <a href="#" className="text-gray-600 hover:text-gray-900">
              Brand
            </a>
            <a href="#" className="text-gray-600 hover:text-gray-900">
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
          <Button variant="outline" size="sm">
            <Save className="w-4 h-4 mr-2" />
            save draft
          </Button>
        </div>
      </header>
      <main className="flex">
        <div className="flex-1 p-6">
          <Card className="bg-gray-100">
            <CardHeader className="flex flex-row items-center gap-2 pb-4">
              <div className="w-6 h-6 bg-gray-300 rounded flex items-center justify-center">
                <Eye className="w-4 h-4 text-gray-600" />
              </div>
              <CardTitle className="text-lg font-medium">Visual Preview</CardTitle>
              <Button variant="ghost" size="sm" className="ml-auto">
                <Type className="w-4 h-4" />
              </Button>
            </CardHeader>
            <CardContent>
              <div className="aspect-square bg-white rounded-lg overflow-hidden relative">
                <Image
                  src="/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png"
                  alt="Caramel Macadamia Latte"
                  width={400}
                  height={400}
                  className="w-full h-full object-cover"
                />
                {textVisible && (
                  <div className="absolute bottom-4 left-4 right-4">
                    <div className="bg-white/90 backdrop-blur-sm rounded-lg p-4">
                      <p
                        className="font-medium mb-2"
                        style={{
                          textAlign,
                          fontSize: `${fontSize[0]}px`,
                          color: textColor,
                        }}
                      >
                        try our new Caramel Macadamia latte!
                      </p>
                      <div className="flex flex-wrap gap-1 text-blue-600 text-sm">
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
        </div>

        <div className="w-80 bg-white border-l border-gray-200 p-4 space-y-4 overflow-y-auto">
          {/* Text Style Panel */}
          <Card className="bg-gray-100">
            <CardContent className="p-4 space-y-4">
              <div className="flex items-center gap-2 mb-4">
                <Type className="w-5 h-5" />
                <span className="font-medium">Text Style</span>
              </div>

              <div>
                <Label className="text-sm font-medium">Font Size</Label>
                <div className="mt-2">
                  <div className="w-full h-2 bg-black rounded-full mb-2"></div>
                  <span className="text-sm">{fontSize[0]}px</span>
                </div>
                <Slider min={12} max={32} step={1} value={fontSize} onValueChange={setFontSize} className="mt-2" />
              </div>

              <div>
                <Label className="text-sm font-medium">Text Color</Label>
                <div className="flex items-center gap-3 mt-2">
                  <div className="w-8 h-8 bg-black rounded border"></div>
                  <Input
                    type="text"
                    value={textColor}
                    onChange={(e) => setTextColor(e.target.value)}
                    className="flex-1"
                  />
                </div>
              </div>

              <div>
                <Label className="text-sm font-medium">Background overlay</Label>
                <div className="flex items-center gap-3 mt-2">
                  <div className="w-8 h-8 bg-white border rounded"></div>
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
          <Card className="bg-gray-200">
            <CardContent className="p-4">
              <div className="flex items-center gap-2 mb-4">
                <Sparkles className="w-5 h-5" />
                <span className="font-medium">Brand Presets</span>
              </div>
              <div className="flex gap-3">
                {brandPresets.map((preset, index) => (
                  <div
                    key={index}
                    className="w-12 h-6 rounded cursor-pointer"
                    style={{ backgroundColor: preset.color }}
                    onClick={() => setTextColor(preset.color)}
                  ></div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Layers Panel */}
          <Card className="bg-gray-200">
            <CardContent className="p-4">
              <div className="flex items-center gap-2 mb-4">
                <Layers className="w-5 h-5" />
                <span className="font-medium">Layers</span>
              </div>
              <div className="space-y-2">
                <div className="flex items-center justify-between py-2">
                  <span className="text-sm">text overlay</span>
                  <Button variant="ghost" size="sm" onClick={() => setTextVisible(!textVisible)}>
                    {textVisible ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                  </Button>
                </div>
                <div className="flex items-center justify-between py-2">
                  <span className="text-sm">Background image</span>
                  <Button variant="ghost" size="sm" onClick={() => setBackgroundVisible(!backgroundVisible)}>
                    {backgroundVisible ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" />}
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Export Panel */}
          <Card className="bg-gray-200">
            <CardContent className="p-4">
              <h3 className="font-medium mb-4">Export</h3>
              <Select defaultValue="instagram">
                <SelectTrigger className="mb-4">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="instagram">Instagram post(1:1)</SelectItem>
                  <SelectItem value="facebook">Facebook post</SelectItem>
                  <SelectItem value="twitter">Twitter post</SelectItem>
                </SelectContent>
              </Select>
              <Button className="w-full bg-black text-white hover:bg-gray-800">
                <Download className="w-4 h-4 mr-2" />
                Download
              </Button>
            </CardContent>
          </Card>
        </div>
      </main>

      <div className="bg-white border-t border-gray-200 p-6">
        <div className="max-w-4xl mx-auto space-y-6">
          {/* Caption Section */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <span className="font-medium">Caption</span>
            </div>
            <div className="flex items-center gap-2 mb-2">
              <Button variant="ghost" size="sm">
                <Type className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="sm">
                <AlignLeft className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="sm">
                <AlignCenter className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="sm">
                <Bold className="w-4 h-4" />
              </Button>
              <Button variant="ghost" size="sm">
                <Italic className="w-4 h-4" />
              </Button>
            </div>
            <Textarea
              value={caption}
              onChange={(e) => setCaption(e.target.value)}
              className="min-h-[100px] resize-none"
              placeholder="Write your caption here..."
            />
            <div className="text-right text-sm text-gray-500 mt-1">{caption.length}/2200 characters</div>
          </div>

          {/* Hashtags Section */}
          <div>
            <div className="flex items-center gap-2 mb-4">
              <Hash className="w-5 h-5" />
              <span className="font-medium">Hashtags</span>
            </div>
            <div className="flex items-center gap-2 mb-4">
              <Input
                placeholder="Add hashtag"
                value={newHashtag}
                onChange={(e) => setNewHashtag(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && addHashtag()}
                className="flex-1"
              />
              <Button onClick={addHashtag} className="bg-blue-900 text-white hover:bg-blue-800">
                <Plus className="w-4 h-4" />
              </Button>
            </div>
            <div className="flex flex-wrap gap-2 mb-2">
              {hashtags.map((hashtag, index) => (
                <Badge key={index} className="bg-orange-500 text-white hover:bg-orange-600 flex items-center gap-1">
                  #{hashtag}
                  <button onClick={() => removeHashtag(hashtag)} className="ml-1 hover:text-gray-200">
                    <X className="w-3 h-3" />
                  </button>
                </Badge>
              ))}
            </div>
            <div className="text-sm text-gray-500">{hashtags.length}/30 hashtags</div>
          </div>
        </div>
      </div>
    </div>
  )
}

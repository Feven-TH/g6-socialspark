"use client"

import { useState } from "react"
import { Button } from "../components/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "../components/card"
import { Textarea } from "../components/textarea"
import { Badge } from "../components/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../components/select"
import { Progress } from "../components/progress"
import {
  Sparkles,
  Instagram,
  Video,
  ImageIcon,
  Download,
  Share2,
  Clock,
  Palette,
  Zap,
  Coffee,
  ShoppingBag,
  Scissors,
  Camera,
  Hash,
  Type,
  Play,
  RotateCcw,
  Settings,
  Languages,
  AlertCircle,
} from "lucide-react"
import { generateCaption, generateImage, generateStoryboard, renderVideo, pollTaskStatus } from "../../lib/api"
import { Alert, AlertDescription } from "../components/alert"

export default function Dashboard() {
  const [language, setLanguage] = useState("en")
  const [currentStep, setCurrentStep] = useState("idea")
  const [idea, setIdea] = useState("")
  const [platform, setPlatform] = useState("instagram")
  const [contentType, setContentType] = useState("image")
  const [tone, setTone] = useState("playful")
  const [businessType, setBusinessType] = useState("cafe")
  const [isGenerating, setIsGenerating] = useState(false)
  const [progress, setProgress] = useState(0)
  const [error, setError] = useState<string | null>(null)
  type GeneratedContent = {
    caption: string
    hashtags: string[]
    imageUrl: string
    videoUrl: string
    taskId: string
  }

  const [generatedContent, setGeneratedContent] = useState<GeneratedContent>({
    caption: "",
    hashtags: [],
    imageUrl: "",
    videoUrl: "",
    taskId: "", // For video rendering
  })

  const translations = {
    en: {
      title: "SocialSpark",
      subtitle: "AI-Powered Content Creation for Ethiopian SMEs",
      ideaPlaceholder: 'Describe your content idea... e.g., "Fun TikTok for my café\'s new latte"',
      generate: "Generate Content",
      regenerate: "Regenerate",
      export: "Export",
      schedule: "Schedule",
      share: "Share Now",
      caption: "Caption",
      hashtags: "Hashtags",
      preview: "Preview",
      brandPresets: "Brand Presets",
      contentLibrary: "Content Library",
      examples: "Try these examples:",
      exampleCafe: "Create a fun TikTok for my café's new caramel macadamia latte",
      exampleSale: "Instagram post for clothing sale, 20% off tees, today only",
      exampleBeauty: "Beauty tip video for natural skincare routine",
    },
    am: {
      title: "ሶሻል ስፓርክ",
      subtitle: "ለኢትዮጵያ አነስተኛ ንግዶች AI የይዘት ፈጠራ መሳሪያ",
      ideaPlaceholder: 'የይዘት ሀሳብዎን ይግለጹ... ለምሳሌ "ለካፌዬ አዲስ ላቴ አዝናኝ ቲክቶክ"',
      generate: "ይዘት ፍጠር",
      regenerate: "እንደገና ፍጠር",
      export: "ወደ ውጭ አውጣ",
      schedule: "ጊዜ ይያዙ",
      share: "አሁን አጋራ",
      caption: "መግለጫ",
      hashtags: "ሃሽታግ",
      preview: "ቅድመ እይታ",
      brandPresets: "የብራንድ ቅንብሮች",
      contentLibrary: "የይዘት ቤተ-መጽሐፍት",
      examples: "እነዚህን ምሳሌዎች ይሞክሩ:",
      exampleCafe: "ለካፌዬ አዲስ ካራሜል ማካዳሚያ ላቴ አዝናኝ ቲክቶክ ፍጠር",
      exampleSale: "ለልብስ ሽያጭ ኢንስታግራም ፖስት፣ 20% ቅናሽ ቲሸርቶች፣ ዛሬ ብቻ",
      exampleBeauty: "ለተፈጥሮ የቆዳ እንክብካቤ ሩቲን የውበት ምክር ቪዲዮ",
    },
  }

  const t = translations[language as keyof typeof translations]

  const handleGenerate = async () => {
    if (!idea.trim()) return

    setIsGenerating(true)
    setProgress(0)
    setCurrentStep("generating")
    setError(null)

    try {
      // Step 1: Generate caption and hashtags
      setProgress(20)
      const captionResponse = await generateCaption(idea, businessType, language)

      setProgress(40)
      setGeneratedContent((prev) => ({
        ...prev,
        caption: captionResponse.caption,
        hashtags: captionResponse.hashtags,
      }))

      // Step 2: Generate image
      setProgress(60)
      const imageResponse = await generateImage(idea, tone)

      setProgress(80)
      setGeneratedContent((prev) => ({
        ...prev,
        imageUrl: imageResponse.image_url,
      }))

      // Step 3: Generate video if needed
      if (contentType === "video") {
        setProgress(85)
        const storyboardResponse = await generateStoryboard(idea, 15)

        setProgress(90)
        const videoResponse = await renderVideo(storyboardResponse.shots)

        setGeneratedContent((prev) => ({
          ...prev,
          taskId: videoResponse.task_id,
        }))

        // Poll for video completion
        setProgress(95)
        const completedTask = await pollTaskStatus(videoResponse.task_id, (status) => {
          console.log("[v0] Video rendering status:", status.status)
        })

        if (completedTask.video_url) {
          setGeneratedContent((prev) => ({
            ...prev,
            videoUrl: completedTask.video_url ?? "",
          }))
        }
      }

      setProgress(100)
      setCurrentStep("preview")
    } catch (err) {
      console.error("[v0] Generation error:", err)
      setError(err instanceof Error ? err.message : "Failed to generate content")
    } finally {
      setIsGenerating(false)
    }
  }

  const businessTypes = [
    { icon: Coffee, label: "Café", value: "cafe" },
    { icon: ShoppingBag, label: "Retail", value: "retail" },
    { icon: Scissors, label: "Salon", value: "salon" },
    { icon: Camera, label: "Photography", value: "photography" },
  ]

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
                <h1 className="text-xl font-black font-montserrat text-foreground">{t.title}</h1>
                <p className="text-sm text-muted-foreground">{t.subtitle}</p>
              </div>
            </div>

            <div className="flex items-center gap-4">
              <nav className="hidden md:flex items-center gap-2">
                <Button variant="ghost" size="sm" asChild>
                  <a href="/library">Library</a>
                </Button>
                <Button variant="ghost" size="sm" asChild>
                  <a href="/editor">Editor</a>
                </Button>
                <Button variant="ghost" size="sm" asChild>
                  <a href="/scheduler">Schedule</a>
                </Button>
                <Button variant="ghost" size="sm" asChild>
                  <a href="/brand-setup">Brand</a>
                </Button>
              </nav>

              <Select value={language} onValueChange={setLanguage}>
                <SelectTrigger className="w-24">
                  <Languages className="w-4 h-4" />
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="en">EN</SelectItem>
                  <SelectItem value="am">አማ</SelectItem>
                </SelectContent>
              </Select>

              <Button variant="outline" size="sm" asChild>
                <a href="/settings">
                  <Settings className="w-4 h-4" />
                </a>
              </Button>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8 max-w-6xl ">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Main Content Creation Panel */}
          <div className="lg:col-span-2 space-y-6">
            {error && (
              <Alert variant="destructive">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            {/* Idea Input Card */}
            <Card className="border-2 border-primary/20 bg-[#D9D9D9]/[0.72]">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 font-montserrat">
                  <Zap className="w-5 h-5 text-secondary" />
                  Content Idea
                </CardTitle>
                <CardDescription>{t.examples}</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Textarea
                  placeholder={t.ideaPlaceholder}
                  value={idea}
                  onChange={(e) => setIdea(e.target.value)}
                  className="min-h-[100px] text-base"
                  dir={language === "am" ? "ltr" : "ltr"}
                />

                {/* Quick Examples */}
                <div className="flex flex-wrap gap-2">
                  <Button variant="outline" size="sm" onClick={() => setIdea(t.exampleCafe)} className="text-xs">
                    {t.exampleCafe.substring(0, 30)}...
                  </Button>
                  <Button variant="outline" size="sm" onClick={() => setIdea(t.exampleSale)} className="text-xs">
                    {t.exampleSale.substring(0, 30)}...
                  </Button>
                </div>

                {/* Business Type and Platform Selection */}
                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <label className="text-sm font-medium mb-2 block">Business Type</label>
                    <Select value={businessType} onValueChange={setBusinessType}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="cafe">Café</SelectItem>
                        <SelectItem value="retail">Retail</SelectItem>
                        <SelectItem value="salon">Salon</SelectItem>
                        <SelectItem value="photography">Photography</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <label className="text-sm font-medium mb-2 block">Platform</label>
                    <Select value={platform} onValueChange={setPlatform}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="instagram">
                          <div className="flex items-center gap-2">
                            <Instagram className="w-4 h-4" />
                            Instagram
                          </div>
                        </SelectItem>
                        <SelectItem value="tiktok">
                          <div className="flex items-center gap-2">
                            <Video className="w-4 h-4" />
                            TikTok
                          </div>
                        </SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <label className="text-sm font-medium mb-2 block">Content Type</label>
                    <Select value={contentType} onValueChange={setContentType}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="image">
                          <div className="flex items-center gap-2">
                            <ImageIcon className="w-4 h-4" />
                            Image Post
                          </div>
                        </SelectItem>
                        <SelectItem value="video">
                          <div className="flex items-center gap-2">
                            <Video className="w-4 h-4" />
                            Short Video
                          </div>
                        </SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                {/* Tone Selection */}
                <div>
                  <label className="text-sm font-medium mb-2 block">Tone</label>
                  <div className="flex flex-wrap gap-2">
                    {["playful", "professional", "casual", "elegant"].map((toneOption) => (
                      <Button
                        key={toneOption}
                        variant={tone === toneOption ? "default" : "outline"}
                        size="sm"
                        onClick={() => setTone(toneOption)}
                        className="capitalize"
                      >
                        {toneOption}
                      </Button>
                    ))}
                  </div>
                </div>

                {/* Generate Button */}
                <Button
                  onClick={handleGenerate}
                  disabled={!idea.trim() || isGenerating}
                  className="w-full h-12 text-base font-semibold"
                  size="lg"
                >
                  {isGenerating ? (
                    <div className="flex items-center gap-2">
                      <div className="w-4 h-4 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin" />
                      Generating...
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      {t.generate}
                    </div>
                  )}
                </Button>

                {/* Progress Bar */}
                {isGenerating && (
                  <div className="space-y-2">
                    <Progress value={progress} className="w-full" />
                    <p className="text-sm text-muted-foreground text-center">
                      {progress < 20
                        ? "Analyzing your idea..."
                        : progress < 40
                          ? "Generating caption..."
                          : progress < 60
                            ? "Creating hashtags..."
                            : progress < 80
                              ? "Generating visual content..."
                              : progress < 95
                                ? "Creating video..."
                                : "Finalizing content..."}
                    </p>
                  </div>
                )}
              </CardContent>
            </Card>

            {/* Generated Content Preview */}
            {currentStep === "preview" && generatedContent.caption && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 font-montserrat">
                    <Camera className="w-5 h-5 text-secondary" />
                    Generated Content
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="grid md:grid-cols-2 gap-6">
                    {/* Caption and Hashtags */}
                    <div className="space-y-4">
                      <div>
                        <div className="flex items-center gap-2 mb-2">
                          <Type className="w-4 h-4" />
                          <label className="font-medium">{t.caption}</label>
                        </div>
                        <Textarea
                          value={generatedContent.caption}
                          onChange={(e) => setGeneratedContent({ ...generatedContent, caption: e.target.value })}
                          className="min-h-[120px]"
                          dir={language === "am" ? "ltr" : "ltr"}
                        />
                      </div>

                      <div>
                        <div className="flex items-center gap-2 mb-2">
                          <Hash className="w-4 h-4" />
                          <label className="font-medium">{t.hashtags}</label>
                        </div>
                        <div className="flex flex-wrap gap-2">
                          {generatedContent.hashtags.map((hashtag, index) => (
                            <Badge key={index} variant="secondary" className="text-xs">
                              #{hashtag}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>

                    {/* Visual Preview */}
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <ImageIcon className="w-4 h-4" />
                        <label className="font-medium">{t.preview}</label>
                      </div>
                      <div className="aspect-square bg-muted rounded-lg overflow-hidden">
                        {contentType === "image" ? (
                          <img
                            src={generatedContent.imageUrl || "/placeholder.svg"}
                            alt="Generated content"
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <div className="w-full h-full bg-muted flex items-center justify-center">
                            {generatedContent.videoUrl ? (
                              <video src={generatedContent.videoUrl} controls className="w-full h-full object-cover" />
                            ) : (
                              <div className="text-center">
                                <Play className="w-12 h-12 mx-auto mb-2 text-muted-foreground" />
                                <p className="text-sm text-muted-foreground">
                                  {generatedContent.taskId ? "Video rendering..." : "Video Preview"}
                                </p>
                              </div>
                            )}
                          </div>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  <div className="flex flex-wrap gap-3 pt-4 border-t">
                    <Button onClick={handleGenerate} variant="outline">
                      <RotateCcw className="w-4 h-4 mr-2" />
                      {t.regenerate}
                    </Button>
                    <Button variant="secondary">
                      <Download className="w-4 h-4 mr-2" />
                      {t.export}
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => {
                        // Save content to localStorage for scheduler
                        localStorage.setItem(
                          "schedulerContent",
                          JSON.stringify({
                            caption: generatedContent.caption,
                            hashtags: generatedContent.hashtags,
                            imageUrl: generatedContent.imageUrl,
                            videoUrl: generatedContent.videoUrl,
                            platform,
                            contentType,
                            tone,
                          }),
                        )
                        window.location.href = "/scheduler"
                      }}
                    >
                      <Clock className="w-4 h-4 mr-2" />
                      {t.schedule}
                    </Button>
                    <Button>
                      <Share2 className="w-4 h-4 mr-2" />
                      {t.share}
                    </Button>
                  </div>
                </CardContent>
              </Card>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            
           
          </div>
        </div>
      </div>
    </div>
  )
}

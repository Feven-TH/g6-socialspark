"use client"

import { useState } from "react"
import { Button } from "../components/button"
import { Card, CardContent } from "../components/card"
import { Input } from "../components/input"
import { Badge } from "../components/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "../components/select"
import {
  Sparkles,
  Search,
  Filter,
  Grid3X3,
  List,
  Download,
  Share2,
  Edit,
  Trash2,
  Instagram,
  Video,
  ImageIcon,
  Calendar,
  Eye,
  Heart,
  MessageCircle,
  Clock,
} from "lucide-react"

export default function LibraryPage() {
  const [viewMode, setViewMode] = useState("grid")
  const [searchQuery, setSearchQuery] = useState("")
  const [filterType, setFilterType] = useState("all")
  const [filterPlatform, setFilterPlatform] = useState("all")

  const mockContent = [
    {
      id: 1,
      title: "Caramel Macadamia Latte",
      type: "image",
      platform: "instagram",
      createdAt: "2024-01-15",
      status: "published",
      engagement: { likes: 45, comments: 8, views: 234 },
      thumbnail: "/ethiopian-cafe-latte-with-caramel-and-macadamia-nu.png",
      caption: "Try our new Caramel Macadamia Latte! Perfect coffee blend...",
      hashtags: ["AddisAbebaCafe", "EthiopianCoffee", "Latte"],
    },
    {
      id: 2,
      title: "Behind the Scenes",
      type: "video",
      platform: "tiktok",
      createdAt: "2024-01-14",
      status: "draft",
      engagement: { likes: 0, comments: 0, views: 0 },
      thumbnail: "/short-video-of-latte-being-made.png",
      caption: "Watch how we make our signature latte...",
      hashtags: ["BehindTheScenes", "CoffeeProcess", "Barista"],
    },
    {
      id: 3,
      title: "Weekend Special",
      type: "image",
      platform: "instagram",
      createdAt: "2024-01-13",
      status: "scheduled",
      engagement: { likes: 0, comments: 0, views: 0 },
      thumbnail: "/weekend-coffee-special.png",
      caption: "Weekend vibes with our special blend...",
      hashtags: ["WeekendSpecial", "CoffeeLovers", "Relax"],
    },
    {
      id: 4,
      title: "Customer Review",
      type: "image",
      platform: "instagram",
      createdAt: "2024-01-12",
      status: "published",
      engagement: { likes: 67, comments: 12, views: 345 },
      thumbnail: "/happy-customer-with-coffee.png",
      caption: "Amazing feedback from our lovely customers...",
      hashtags: ["CustomerLove", "Reviews", "HappyCustomers"],
    },
  ]

  const filteredContent = mockContent.filter((item) => {
    const matchesSearch =
      item.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.caption.toLowerCase().includes(searchQuery.toLowerCase())
    const matchesType = filterType === "all" || item.type === filterType
    const matchesPlatform = filterPlatform === "all" || item.platform === filterPlatform

    return matchesSearch && matchesType && matchesPlatform
  })

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
                <h1 className="text-xl font-black font-montserrat text-foreground">Content Library</h1>
                <p className="text-sm text-muted-foreground">Manage your created content</p>
              </div>
            </div>

            <Button asChild>
              <a href="/">
                <Sparkles className="w-4 h-4 mr-2" />
                Create New
              </a>
            </Button>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        {/* Filters and Search */}
        <div className="flex flex-col md:flex-row gap-4 mb-8">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search your content..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div className="flex gap-2">
            <Select value={filterType} onValueChange={setFilterType}>
              <SelectTrigger className="w-32">
                <Filter className="w-4 h-4 mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="image">Images</SelectItem>
                <SelectItem value="video">Videos</SelectItem>
              </SelectContent>
            </Select>

            <Select value={filterPlatform} onValueChange={setFilterPlatform}>
              <SelectTrigger className="w-32">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Platforms</SelectItem>
                <SelectItem value="instagram">Instagram</SelectItem>
                <SelectItem value="tiktok">TikTok</SelectItem>
              </SelectContent>
            </Select>

            <div className="flex border rounded-lg">
              <Button
                variant={viewMode === "grid" ? "default" : "ghost"}
                size="sm"
                onClick={() => setViewMode("grid")}
                className="rounded-r-none"
              >
                <Grid3X3 className="w-4 h-4" />
              </Button>
              <Button
                variant={viewMode === "list" ? "default" : "ghost"}
                size="sm"
                onClick={() => setViewMode("list")}
                className="rounded-l-none"
              >
                <List className="w-4 h-4" />
              </Button>
            </div>
          </div>
        </div>

        {/* Content Grid/List */}
        {viewMode === "grid" ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 ">
            {filteredContent.map((item) => (
              <Card key={item.id} className="group hover:shadow-lg transition-shadow  bg-[#D9D9D9]/[0.72]" >
                <div className="relative aspect-square overflow-hidden rounded-t-lg">
                  <img
                    src={item.thumbnail || "/placeholder.svg"}
                    alt={item.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                  />
                  <div className="absolute top-2 left-2">
                    <Badge
                      variant={
                        item.status === "published" ? "default" : item.status === "scheduled" ? "secondary" : "outline"
                      }
                    >
                      {item.status}
                    </Badge>
                  </div>
                  <div className="absolute top-2 right-2 flex gap-1">
                    {item.platform === "instagram" ? (
                      <Instagram className="w-4 h-4 text-white bg-black/50 rounded p-0.5" />
                    ) : (
                      <Video className="w-4 h-4 text-white bg-black/50 rounded p-0.5" />
                    )}
                    {item.type === "video" && <Video className="w-4 h-4 text-white bg-black/50 rounded p-0.5" />}
                  </div>
                  <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
                    <div className="flex gap-2">
                      <Button size="sm" variant="secondary">
                        <Eye className="w-4 h-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant="secondary"
                        onClick={() => {
                          localStorage.setItem(
                            "editorContent",
                            JSON.stringify({
                              caption: item.caption,
                              hashtags: item.hashtags,
                              imageUrl: item.thumbnail,
                              platform: item.platform,
                              contentType: item.type,
                              title: item.title,
                            }),
                          )
                          window.location.href = "/editor"
                        }}
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </div>
                <CardContent className="p-4">
                  <h3 className="font-semibold mb-2 truncate">{item.title}</h3>
                  <p className="text-sm text-muted-foreground mb-3 line-clamp-2">{item.caption}</p>

                  {item.status === "published" && (
                    <div className="flex items-center gap-4 text-xs text-muted-foreground mb-3">
                      <div className="flex items-center gap-1">
                        <Heart className="w-3 h-3" />
                        {item.engagement.likes}
                      </div>
                      <div className="flex items-center gap-1">
                        <MessageCircle className="w-3 h-3" />
                        {item.engagement.comments}
                      </div>
                      <div className="flex items-center gap-1">
                        <Eye className="w-3 h-3" />
                        {item.engagement.views}
                      </div>
                    </div>
                  )}

                  <div className="flex flex-wrap gap-1 mb-3">
                    {item.hashtags.slice(0, 2).map((hashtag, index) => (
                      <Badge key={index} variant="outline" className="text-xs">
                        #{hashtag}
                      </Badge>
                    ))}
                    {item.hashtags.length > 2 && (
                      <Badge variant="outline" className="text-xs">
                        +{item.hashtags.length - 2}
                      </Badge>
                    )}
                  </div>

                  <div className="flex items-center justify-between">
                    <span className="text-xs text-muted-foreground">
                      {new Date(item.createdAt).toLocaleDateString()}
                    </span>
                    <div className="flex gap-1">
                      <Button size="sm" variant="ghost">
                        <Download className="w-4 h-4" />
                      </Button>
                      <Button size="sm" variant="ghost">
                        <Share2 className="w-4 h-4" />
                      </Button>
                      <Button size="sm" variant="ghost">
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        ) : (
          <div className="space-y-4">
            {filteredContent.map((item) => (
              <Card key={item.id}>
                <CardContent className="p-6">
                  <div className="flex items-center gap-4">
                    <div className="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
                      <img
                        src={item.thumbnail || "/placeholder.svg"}
                        alt={item.title}
                        className="w-full h-full object-cover"
                      />
                    </div>

                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-semibold truncate">{item.title}</h3>
                        <Badge
                          variant={
                            item.status === "published"
                              ? "default"
                              : item.status === "scheduled"
                                ? "secondary"
                                : "outline"
                          }
                        >
                          {item.status}
                        </Badge>
                      </div>

                      <p className="text-sm text-muted-foreground mb-2 line-clamp-1">{item.caption}</p>

                      <div className="flex items-center gap-4 text-xs text-muted-foreground">
                        <div className="flex items-center gap-1">
                          {item.platform === "instagram" ? (
                            <Instagram className="w-3 h-3" />
                          ) : (
                            <Video className="w-3 h-3" />
                          )}
                          {item.platform}
                        </div>
                        <div className="flex items-center gap-1">
                          {item.type === "image" ? <ImageIcon className="w-3 h-3" /> : <Video className="w-3 h-3" />}
                          {item.type}
                        </div>
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          {new Date(item.createdAt).toLocaleDateString()}
                        </div>
                        {item.status === "published" && (
                          <>
                            <div className="flex items-center gap-1">
                              <Heart className="w-3 h-3" />
                              {item.engagement.likes}
                            </div>
                            <div className="flex items-center gap-1">
                              <MessageCircle className="w-3 h-3" />
                              {item.engagement.comments}
                            </div>
                          </>
                        )}
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      <Button size="sm" variant="outline">
                        <Eye className="w-4 h-4 mr-2" />
                        View
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => {
                          localStorage.setItem(
                            "editorContent",
                            JSON.stringify({
                              caption: item.caption,
                              hashtags: item.hashtags,
                              imageUrl: item.thumbnail,
                              platform: item.platform,
                              contentType: item.type,
                              title: item.title,
                            }),
                          )
                          window.location.href = "/editor"
                        }}
                      >
                        <Edit className="w-4 h-4 mr-2" />
                        Edit
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => {
                          localStorage.setItem(
                            "schedulerContent",
                            JSON.stringify({
                              caption: item.caption,
                              hashtags: item.hashtags,
                              imageUrl: item.thumbnail,
                              platform: item.platform,
                              contentType: item.type,
                              title: item.title,
                            }),
                          )
                          window.location.href = "/scheduler"
                        }}
                      >
                        <Clock className="w-4 h-4 mr-2" />
                        Schedule
                      </Button>
                      <Button size="sm" variant="ghost">
                        <Download className="w-4 h-4" />
                      </Button>
                      <Button size="sm" variant="ghost">
                        <Share2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}

        {filteredContent.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-muted rounded-full flex items-center justify-center mx-auto mb-4">
              <Search className="w-8 h-8 text-muted-foreground" />
            </div>
            <h3 className="text-lg font-semibold mb-2">No content found</h3>
            <p className="text-muted-foreground mb-4">
              {searchQuery ? "Try adjusting your search terms" : "Start creating your first piece of content"}
            </p>
            <Button asChild>
              <a href="/">
                <Sparkles className="w-4 h-4 mr-2" />
                Create Content
              </a>
            </Button>
          </div>
        )}
      </div>
    </div>
  )
}

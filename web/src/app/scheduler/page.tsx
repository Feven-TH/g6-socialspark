"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/card";
import { Label } from "@/components/label";
import { Badge } from "@/components/badge";
import { Calendar } from "@/components/calendar";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/select";
import {
  Sparkles,
  CalendarIcon,
  Clock,
  Instagram,
  Video,
  Plus,
  Edit,
  Trash2,
  Send,
  Pause,
  Play,
} from "lucide-react";
import Footer from "@/components/footer";

// ----- Types -----
interface EditorContent {
  image?: string;
  caption?: string;
  hashtags?: string[];
}

interface ScheduledPost {
  id: number;
  title: string;
  platform: "instagram" | "tiktok";
  scheduledFor: string;
  status: "scheduled" | "paused";
  thumbnail?: string;
  caption: string;
}

export default function SchedulerPage() {
    const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date());

  const [selectedTime, setSelectedTime] = useState<string>("09:00");
  const [selectedPlatform, setSelectedPlatform] = useState<
    "instagram" | "tiktok"
  >("instagram");
  const [editorContent, setEditorContent] = useState<EditorContent | null>(
    null
  );

  useEffect(() => {
    const savedContent = localStorage.getItem("editorContent");
    if (savedContent) {
      setEditorContent(JSON.parse(savedContent));
    }
  }, []);

  const scheduledPosts: ScheduledPost[] = [
    {
      id: 1,
      title: "Morning Coffee Special",
      platform: "instagram",
      scheduledFor: "2024-01-16T09:00:00",
      status: "scheduled",
      thumbnail: "/morning-coffee-still-life.png",
      caption: "Start your day with our signature blend...",
    },
    {
      id: 2,
      title: "Behind the Scenes",
      platform: "tiktok",
      scheduledFor: "2024-01-16T15:30:00",
      status: "scheduled",
      thumbnail: "/coffee-making-process.png",
      caption: "Watch how we craft the perfect cup...",
    },
    {
      id: 3,
      title: "Weekend Vibes",
      platform: "instagram",
      scheduledFor: "2024-01-17T11:00:00",
      status: "paused",
      thumbnail: "/weekend-coffee-atmosphere.png",
      caption: "Relax and unwind with us this weekend...",
    },
  ];

  const optimalTimes: Record<"instagram" | "tiktok", string[]> = {
    instagram: ["09:00", "12:00", "17:00", "20:00"],
    tiktok: ["06:00", "10:00", "19:00", "21:00"],
  };

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
                <h1 className="text-xl font-black font-montserrat text-foreground">
                  Content Scheduler
                </h1>
                <p className="text-sm text-muted-foreground">
                  Plan and schedule your posts
                </p>
              </div>
            </div>

            <div className="flex items-center gap-6">
              <nav className="hidden md:flex items-center gap-6">
                <a
                  href="/library"
                  className="text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Library
                </a>
                <a
                  href="/editor"
                  className="text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Editor
                </a>
                <a
                  href="/schedule"
                  className="text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Schedule
                </a>
                <a
                  href="/brand"
                  className="text-sm font-medium text-muted-foreground hover:text-foreground"
                >
                  Brand
                </a>
              </nav>

              <div className="flex items-center gap-2">
                <Button variant="outline" asChild>
                  <a href="/editor">
                    <Edit className="w-4 h-4 mr-2" />
                    Back to Editor
                  </a>
                </Button>
                <Button asChild>
                  <a href="/dashboard">
                    <Plus className="w-4 h-4 mr-2" />
                    Create New
                  </a>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Scheduling Panel */}
          <div className="lg:col-span-2 space-y-6">
            {editorContent && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Edit className="w-5 h-5" />
                    Content Preview
                  </CardTitle>
                  <CardDescription>
                    Content from editor ready to schedule
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex gap-4 p-4 border rounded-lg bg-muted/50">
                    <div className="w-20 h-20 rounded-lg overflow-hidden flex-shrink-0">
                      <img
                        src={editorContent?.image || "/placeholder.svg"}
                        alt="Content preview"
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm mb-2 line-clamp-2">
                        {editorContent?.caption || "No caption"}
                      </p>
                      <div className="flex flex-wrap gap-1 mb-2">
                        {editorContent?.hashtags
                          ?.slice(0, 3)
                          .map((hashtag, index) => (
                            <span key={index} className="text-xs text-blue-600">
                              #{hashtag}
                            </span>
                          ))}
                        {editorContent?.hashtags &&
                          editorContent.hashtags.length > 3 && (
                            <span className="text-xs text-muted-foreground">
                              +{editorContent.hashtags.length - 3} more
                            </span>
                          )}
                      </div>
                      <Badge variant="secondary" className="text-xs">
                        Ready to schedule
                      </Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Quick Schedule */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <CalendarIcon className="w-5 h-5" />
                  Schedule New Post
                </CardTitle>
                <CardDescription>
                  Select date, time, and platform for your content
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="grid md:grid-cols-2 gap-6">
                  <div className="space-y-4">
                    <div className="space-y-2">
                      <Label>Platform</Label>
                      <Select
                        value={selectedPlatform}
                        onValueChange={(value) =>
                          setSelectedPlatform(value as "instagram" | "tiktok")
                        }
                      >
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

                    <div className="space-y-2">
                      <Label>Time</Label>
                      <Select
                        value={selectedTime}
                        onValueChange={setSelectedTime}
                      >
                        <SelectTrigger>
                          <Clock className="w-4 h-4 mr-2" />
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {Array.from({ length: 24 }, (_, i) => {
                            const hour = i.toString().padStart(2, "0");
                            return (
                              <SelectItem key={hour} value={`${hour}:00`}>
                                {hour}:00
                              </SelectItem>
                            );
                          })}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label>Optimal Times for {selectedPlatform}</Label>
                      <div className="flex flex-wrap gap-2">
                        {optimalTimes[selectedPlatform].map((time) => (
                          <Button
                            key={time}
                            variant={
                              selectedTime === time ? "default" : "outline"
                            }
                            size="sm"
                            onClick={() => setSelectedTime(time)}
                          >
                            {time}
                          </Button>
                        ))}
                      </div>
                    </div>
                  </div>

                  <div className="space-y-4">
                    <Label>Select Date</Label>
                    

<Calendar
  mode="single"
  selected={selectedDate}
  onSelect={(date) => setSelectedDate(date || undefined)}
  className="rounded-md border"
  disabled={(date) => date < new Date()}
  required
/>

                  </div>
                </div>

                <div className="flex gap-4 pt-4 border-t">
                  <Button className="flex-1">
                    <Send className="w-4 h-4 mr-2" />
                    {editorContent ? "Schedule This Content" : "Schedule Post"}
                  </Button>
                  <Button variant="outline">
                    <Plus className="w-4 h-4 mr-2" />
                    Save as Draft
                  </Button>
                </div>
              </CardContent>
            </Card>

            {/* Scheduled Posts */}
            <Card>
              <CardHeader>
                <CardTitle>Scheduled Posts</CardTitle>
                <CardDescription>Manage your upcoming content</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {scheduledPosts.map((post) => (
                    <div
                      key={post.id}
                      className="flex items-center gap-4 p-4 border rounded-lg"
                    >
                      <div className="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
                        <img
                          src={post.thumbnail || "/placeholder.svg"}
                          alt={post.title}
                          className="w-full h-full object-cover"
                        />
                      </div>

                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold truncate">
                            {post.title}
                          </h3>
                          <Badge
                            variant={
                              post.status === "scheduled"
                                ? "default"
                                : "secondary"
                            }
                          >
                            {post.status}
                          </Badge>
                        </div>

                        <p className="text-sm text-muted-foreground mb-2 line-clamp-1">
                          {post.caption}
                        </p>

                        <div className="flex items-center gap-4 text-xs text-muted-foreground">
                          <div className="flex items-center gap-1">
                            {post.platform === "instagram" ? (
                              <Instagram className="w-3 h-3" />
                            ) : (
                              <Video className="w-3 h-3" />
                            )}
                            {post.platform}
                          </div>
                          <div className="flex items-center gap-1">
                            <CalendarIcon className="w-3 h-3" />
                            {new Date(post.scheduledFor).toLocaleDateString()}
                          </div>
                          <div className="flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {new Date(post.scheduledFor).toLocaleTimeString(
                              [],
                              {
                                hour: "2-digit",
                                minute: "2-digit",
                              }
                            )}
                          </div>
                        </div>
                      </div>

                      <div className="flex items-center gap-2">
                        {post.status === "scheduled" ? (
                          <Button size="sm" variant="outline">
                            <Pause className="w-4 h-4" />
                          </Button>
                        ) : (
                          <Button size="sm" variant="outline">
                            <Play className="w-4 h-4" />
                          </Button>
                        )}
                        <Button size="sm" variant="outline">
                          <Edit className="w-4 h-4" />
                        </Button>
                        <Button size="sm" variant="ghost">
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Analytics & Insights */}
          <div className="space-y-6">
            {/* Best Times */}
            <Card>
              <CardHeader>
                <CardTitle>Best Posting Times</CardTitle>
                <CardDescription>
                  Based on your audience engagement
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Instagram className="w-4 h-4" />
                      <span className="text-sm">Instagram</span>
                    </div>
                    <Badge variant="outline">9 AM, 12 PM, 5 PM</Badge>
                  </div>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Video className="w-4 h-4" />
                      <span className="text-sm">TikTok</span>
                    </div>
                    <Badge variant="outline">6 AM, 10 AM, 7 PM</Badge>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Weekly Schedule */}
            <Card>
              <CardHeader>
                <CardTitle>This Week&apos;s Schedule</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(
                    (day, index) => (
                      <div
                        key={day}
                        className="flex items-center justify-between"
                      >
                        <span className="text-sm font-medium">{day}</span>
                        <div className="flex gap-1">
                          {index < 3 && (
                            <div className="w-2 h-2 bg-primary rounded-full"></div>
                          )}
                          {index === 1 && (
                            <div className="w-2 h-2 bg-secondary rounded-full"></div>
                          )}
                          {index > 4 && (
                            <div className="w-2 h-2 bg-muted rounded-full"></div>
                          )}
                        </div>
                      </div>
                    )
                  )}
                </div>
              </CardContent>
            </Card>

            {/* Quick Actions */}
            <Card>
              <CardHeader>
                <CardTitle>Quick Actions</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <Button
                  variant="outline"
                  className="w-full justify-start bg-transparent"
                  asChild
                >
                  <a href="/library">
                    <Plus className="w-4 h-4 mr-2" />
                    Schedule from Library
                  </a>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}

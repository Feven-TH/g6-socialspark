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
  ArrowLeft,
} from "lucide-react";
import Footer from "@/components/footer";
import Schedulerheader from "@/components/schedulerheader";


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
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(
    new Date()
  );

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
      <Schedulerheader />
      <div className="container mx-auto px-4 py-8">
        <div className="grid lg:grid-cols-3 gap-8">
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

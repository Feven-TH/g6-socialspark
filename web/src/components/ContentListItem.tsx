import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/button";
import { Card, CardContent } from "@/components/card";
import { Badge } from "@/components/badge";
import {
  Download,
  Share2,
  Edit,
  Trash2,
  Instagram,
  Video,
  Eye,
  Heart,
  MessageCircle,
  Clock,
  Copy,
  Check,
  ImageIcon,
  Calendar,
} from "lucide-react";
import { LibraryItem } from "@/types/library";

interface ContentListItemProps {
  item: LibraryItem;
  copiedId: number | null;
  onExport: (item: LibraryItem) => void;
  onCopy: (item: LibraryItem) => void;
  onCopyHashtags: (item: LibraryItem) => void;
  onEdit: (item: LibraryItem) => void;
  onSchedule: (item: LibraryItem) => void;
  onDelete: (item: LibraryItem) => void;
}

export default function ContentListItem({
  item,
  copiedId,
  onExport,
  onCopy,
  onCopyHashtags,
  onEdit,
  onSchedule,
  onDelete,
}: ContentListItemProps) {
  return (
    <Card>
      <CardContent className="p-6">
        <div className="flex items-center gap-4">
          <div className="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
            <Image
              src={item.imageUrl || "/placeholder.svg"}
              alt={item.title}
              width={64}
              height={64}
              className="object-cover"
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

            <p className="text-sm text-muted-foreground mb-2 line-clamp-1">
              {item.caption}
            </p>

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
                {item.type === "image" ? (
                  <ImageIcon className="w-3 h-3" />
                ) : (
                  <Video className="w-3 h-3" />
                )}
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
            <Link href={`/view/${item.id}`}>
              <Button size="sm" variant="outline" className="flex items-center">
                <Eye className="w-4 h-4 mr-2" />
                View
              </Button>
            </Link>

            <Button size="sm" variant="outline" onClick={() => onEdit(item)}>
              <Edit className="w-4 h-4 mr-2" />
              Edit
            </Button>

            <Button
              size="sm"
              variant="outline"
              onClick={() => onSchedule(item)}
            >
              <Clock className="w-4 h-4 mr-2" />
              Schedule
            </Button>

            <Button
              size="sm"
              variant="ghost"
              onClick={() => onExport(item)}
              title="Export as image"
            >
              <Download className="w-4 h-4" />
            </Button>

            <Button
              size="sm"
              variant="ghost"
              onClick={() => onCopy(item)}
              title="Copy caption and hashtags"
            >
              {copiedId === item.id ? (
                <Check className="w-4 h-4 text-green-600" />
              ) : (
                <Copy className="w-4 h-4" />
              )}
            </Button>

            <Button
              size="sm"
              variant="ghost"
              onClick={() => onCopyHashtags(item)}
              title="Copy hashtags only"
            >
              <Share2 className="w-4 h-4" />
            </Button>

            <Button
              size="sm"
              variant="ghost"
              onClick={() => onDelete(item)}
              title="Delete snap"
            >
              <Trash2 className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

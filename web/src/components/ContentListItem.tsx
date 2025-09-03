import Link from "next/link";
import Image from "next/image";
import { Button } from "@/components/button";
import { Card, CardContent } from "@/components/card";
import { Badge } from "@/components/badge";
import {
  Download,
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
  Share,
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
      <CardContent className="p-4 sm:p-6">
        <div className="flex flex-col sm:flex-row sm:items-start gap-4">
          {/* Image */}
          <div className="w-16 h-16 rounded-lg overflow-hidden flex-shrink-0">
            <Image
              src={item.imageUrl || "/placeholder.svg"}
              alt={item.title}
              width={64}
              height={64}
              className="object-cover"
            />
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0 flex flex-col gap-2">
            {/* Title + Status */}
            <div className="flex flex-col sm:flex-row sm:items-center gap-2">
              <h3 className="font-semibold text-sm sm:text-base break-words line-clamp-2">
                {item.title}
              </h3>
              <Badge
                variant={
                  item.status === "published"
                    ? "default"
                    : item.status === "scheduled"
                    ? "secondary"
                    : "outline"
                }
                className="self-start sm:self-center text-xs sm:text-sm"
              >
                {item.status}
              </Badge>
            </div>

            {/* Caption */}
            <p className="text-xs sm:text-sm text-muted-foreground line-clamp-2 break-words">
              {item.caption}
            </p>

            {/* Hashtags */}
            <div className="flex flex-wrap gap-1">
              {item.hashtags.map((hashtag, index) => (
                <Badge
                  key={index}
                  variant="outline"
                  className="text-xs sm:text-sm px-2 py-1 break-all"
                >
                  #{hashtag}
                </Badge>
              ))}
            </div>

            {/* Metadata */}
            <div className="flex flex-col sm:flex-row sm:items-center flex-wrap gap-2 sm:gap-4 text-xs sm:text-sm text-muted-foreground">
              <div className="flex items-center gap-1">
                {item.platform === "instagram" ? (
                  <Instagram className="w-3 h-3 sm:w-4 sm:h-4" />
                ) : (
                  <Video className="w-3 h-3 sm:w-4 sm:h-4" />
                )}
                <span className="hidden sm:inline">{item.platform}</span>
              </div>
              <div className="flex items-center gap-1">
                {item.type === "image" ? (
                  <ImageIcon className="w-3 h-3 sm:w-4 sm:h-4" />
                ) : (
                  <Video className="w-3 h-3 sm:w-4 sm:h-4" />
                )}
                <span className="hidden sm:inline">{item.type}</span>
              </div>
              <div className="flex items-center gap-1">
                <Calendar className="w-3 h-3 sm:w-4 sm:h-4" />
                {new Date(item.createdAt).toLocaleDateString()}
              </div>
              {item.status === "published" && (
                <>
                  <div className="flex items-center gap-1">
                    <Heart className="w-3 h-3 sm:w-4 sm:h-4" />
                    {item.engagement.likes}
                  </div>
                  <div className="flex items-center gap-1">
                    <MessageCircle className="w-3 h-3 sm:w-4 sm:h-4" />
                    {item.engagement.comments}
                  </div>
                </>
              )}
            </div>
          </div>

          {/* Actions + Utilities */}
          <div className="flex flex-wrap sm:flex-nowrap items-stretch sm:items-center gap-2 w-full sm:w-auto mt-2 sm:mt-0">
            {/* Edit / View / Schedule */}
            <div className="flex flex-row flex-nowrap gap-1 w-full sm:w-auto justify-between mt-2 sm:mt-0">
              <Link href={`/view/${item.id}`}>
                <Button
                  size="sm"
                  variant="outline"
                  className="flex-1 flex justify-center p-2"
                  title="watch detailed view"
                >
                  <Eye className="w-4 h-4" />
                </Button>
              </Link>

              <Button
                size="sm"
                variant="outline"
                onClick={() => onEdit(item)}
                title="Edit"
                className="flex-1 flex justify-center p-2"
              >
                <Edit className="w-4 h-4" />
              </Button>

              <Button
                size="sm"
                variant="outline"
                onClick={() => onSchedule(item)}
                title="schedule"
                className="flex-1 flex justify-center p-2"
              >
                <Clock className="w-4 h-4" />
              </Button>
            </div>

            {/* Utility buttons */}
            <div className="flex flex-wrap gap-1 justify-start w-full sm:w-auto mt-2 sm:mt-0">
              <Button
                size="sm"
                variant="ghost"
                onClick={() => onExport(item)}
                title="Export as image"
                className="p-1 sm:p-2"
              >
                <Download className="w-3 h-3 sm:w-4 sm:h-4" />
              </Button>

              <Button
                size="sm"
                variant="ghost"
                onClick={() => onCopy(item)}
                title="Copy caption and hashtags"
                className="p-1 sm:p-2"
              >
                {copiedId === item.id ? (
                  <Check className="w-3 h-3 sm:w-4 sm:h-4 text-green-600" />
                ) : (
                  <Copy className="w-3 h-3 sm:w-4 sm:h-4" />
                )}
              </Button>

              <Button
                size="sm"
                variant="ghost"
                onClick={() => onDelete(item)}
                title="Delete snap"
                className="p-1 sm:p-2"
              >
                <Trash2 className="w-3 h-3 sm:w-4 sm:h-4" />
              </Button>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

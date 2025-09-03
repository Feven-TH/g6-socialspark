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
  Clock,
  Copy,
  Check,
  Share,
} from "lucide-react";
import { LibraryItem } from "@/types/library";

interface ContentCardProps {
  item: LibraryItem;
  copiedId: number | null;
  onExport: (item: LibraryItem) => void;
  onCopy: (item: LibraryItem) => void;
  onEdit: (item: LibraryItem) => void;
  onSchedule: (item: LibraryItem) => void;
  onDelete: (item: LibraryItem) => void;
}

export default function ContentCard({
  item,
  copiedId,
  onExport,
  onCopy,
  onEdit,
  onSchedule,
  onDelete,
}: ContentCardProps) {
  return (
    <Card className="group hover:shadow-lg transition-shadow bg-[#D9D9D9]/[0.72]">
      <div className="relative aspect-square overflow-hidden rounded-t-lg">
        <Image
          src={item.imageUrl || "/placeholder.svg"}
          alt={item.title}
          fill
          className="object-cover group-hover:scale-105 transition-transform"
        />
        <div className="absolute top-2 left-2">
          <Badge
            variant={
              item.status === "draft"
                ? "default"
                : item.status === "scheduled"
                ? "secondary"
                : "outline"
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
          {item.contentType === "video" && (
            <Video className="w-4 h-4 text-white bg-black/50 rounded p-0.5" />
          )}
        </div>
        {/* Hover Overlay Buttons */}
        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-colors flex items-center justify-center opacity-0 group-hover:opacity-100">
          <div className="flex gap-2">
            <Link href={`/view/${item.id}`} passHref>
              <Button
                size="sm"
                variant="secondary"
                className="flex items-center"
              >
                <Eye className="w-4 h-4" />
              </Button>
            </Link>

            <Button size="sm" variant="secondary" onClick={() => onEdit(item)}>
              <Edit className="w-4 h-4" />
            </Button>
          </div>
        </div>
      </div>
      <CardContent className="p-3 sm:p-4">
        <h3 className="font-semibold mb-2 text-sm sm:text-base break-words line-clamp-2">
          {item.title}
        </h3>
        <p className="text-xs sm:text-sm text-muted-foreground mb-3 line-clamp-3 break-words">
          {item.caption}
        </p>

        {/* Hashtags - Mobile responsive with full visibility */}
        <div className="flex flex-wrap gap-1 mb-3">
          {item.hashtags.map((hashtag, index) => (
            <Badge
              key={index}
              variant="outline"
              className="text-xs px-2 py-1 break-all"
            >
              #{hashtag}
            </Badge>
          ))}
        </div>
        <div className="flex items-center justify-between">
          <span className="text-xs text-muted-foreground">
            {new Date(item.createdAt).toLocaleDateString()}
          </span>
          <div className="flex gap-1">
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
              onClick={() => onSchedule(item)}
              title="Schedule snap"
              className="p-1 sm:p-2"
            >
              <Clock className="w-3 h-3 sm:w-4 sm:h-4" />
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
      </CardContent>
    </Card>
  );
}

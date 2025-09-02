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
              item.type === "draft"
                ? "default"
                : item.type === "scheduled"
                ? "secondary"
                : "outline"
            }
          >
            {item.type}
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
      <CardContent className="p-4">
        <h3 className="font-semibold mb-2 truncate">{item.title}</h3>
        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
          {item.caption}
        </p>

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
              onClick={() => onSchedule(item)}
              title="Schedule snap"
            >
              <Clock className="w-4 h-4" />
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

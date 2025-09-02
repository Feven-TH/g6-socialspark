import { Check, AlertTriangle } from "lucide-react";
import { ToastState } from "@/types/library";

interface ToastProps {
  toast: ToastState;
}

export default function Toast({ toast }: ToastProps) {
  if (!toast.show) return null;

  return (
    <div
      className={`fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg ${
        toast.type === "success" ? "bg-green-500" : "bg-red-500"
      } text-white`}
    >
      <div className="flex items-center gap-2">
        {toast.type === "success" ? (
          <Check className="w-4 h-4" />
        ) : (
          <AlertTriangle className="w-4 h-4" />
        )}
        {toast.message}
      </div>
    </div>
  );
}

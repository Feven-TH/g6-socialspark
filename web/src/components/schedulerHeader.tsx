"use client";

import React from "react";
import { useRouter } from "next/navigation";
import { Button } from "./button";
import { ArrowLeft } from "lucide-react";

const Header = () => {
  const router = useRouter();

  const handleBack = () => {
    if (window.history.length > 1) {
      router.back(); // Go to previous page
    } else {
      router.push("/"); // Go to home if no previous history
    }
  };

  return (
    <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        
        {/* Left side: Title and subtitle */}
        <div className="text-left">
          <h1 className="text-xl font-black font-montserrat text-foreground">
            Content Scheduler
          </h1>
          <p className="text-sm text-muted-foreground">
            Plan and schedule your posts
          </p>
        </div>

        {/* Right side: Back button */}
        <div>
          <Button variant="outline" className="flex items-center gap-2" onClick={handleBack}>
            <ArrowLeft className="w-4 h-4" />
            Back
          </Button>
        </div>
      </div>
    </header>
  );
};

export default Header;

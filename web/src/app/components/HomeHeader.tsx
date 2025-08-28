"use client";
import React from "react";
import Link from "next/link";
import { Button } from "./button";
import { Sparkles } from "lucide-react";

const Header = () => {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-white/90 backdrop-blur-md">
      <div className="max-w-6xl mx-auto flex items-center justify-between px-6 py-4">
        {/* Logo */}
        <Link href="/" className="flex items-center gap-2 font-bold text-xl">
          <div className="flex items-center gap-3 mb-0">
            <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <Sparkles className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="text-lg font-bold font-montserrat">
              SocialSpark
            </span>
          </div>
        </Link>

        {/* Nav Links */}
        <nav className="flex items-center gap-6 text-sm font-medium">
          {/* Desktop links */}
          <Link
            href="#features"
            className="hidden md:block text-[#0D2A4B] hover:text-[#2EC4B6]"
          >
            Features
          </Link>
          <Link
            href="/auth/login"
            className="hidden md:block text-[#0D2A4B] hover:text-[#2EC4B6]"
          >
            Sign in
          </Link>

          {/* Always show Get started */}
          <Button
            asChild
            className="bg-[#FBBF24] text-[#0D2A4B] hover:bg-[#facc15] rounded-lg px-4 py-2 font-semibold"
          >
            <Link href="/auth/signup">Get started</Link>
          </Button>
        </nav>
      </div>
    </header>
  );
};

export default Header;

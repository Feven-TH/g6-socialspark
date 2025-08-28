import React from "react";
import Link from "next/link";
import { Button } from "./button";

const Header = () => {
  return (
    <header className="border-b bg-white backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        {/* Left side: Brand title */}
        <div className="flex items-center gap-4">
          <h1 className="text-2xl font-bold text-gray-900 font-montserrat">Socialspark</h1>
          
          {/* Navigation links */}
          <nav className="flex items-center gap-6 text-sm text-gray-700 font-medium">
            <Link href="/library" className="hover:text-gray-900">Library</Link>
            <Link href="/editor" className="hover:text-gray-900">Editor</Link>
            <Link href="/schedule" className="hover:text-gray-900">Schedule</Link>
            <Link href="/brand" className="hover:text-gray-900">Brand</Link>
          </nav>
        </div>

        {/* Right side: Language selector and user menu */}
        <div className="flex items-center gap-4">
          {/* Language selector */}
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <span>EN</span>
            <span className="text-gray-400">|</span>
            <span className="text-gray-400">v</span>
          </div>
          
          {/* User menu/icon */}
          <div className="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center">
            <span className="text-sm font-semibold text-gray-700">密</span>
          </div>
        </div>
      </div>

      {/* Subtitle section */}
      <div className="bg-gradient-to-r from-blue-50 to-purple-50 py-6">
        <div className="container mx-auto px-4">
          <h2 className="text-xl font-semibold text-center text-gray-800">
            AI-Powered Content Creation for Ethiopian SMEs
          </h2>
        </div>
      </div>
    </header>
  );
};

export default Header;
"use client"

import React, { useState } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { Sparkles, Languages } from "lucide-react"

const Header = () => {
  const pathname = usePathname()
  const [lang, setLang] = useState<"EN" | "አማ">("EN")

  const links = [
    { href: "/dashboard", label: lang === "EN" ? "Dashboard" : "ዳሽቦርድ" },
    { href: "/Brand", label: lang === "EN" ? "Brand" : "ብራንድ" },
    { href: "/library", label: lang === "EN" ? "Library" : "ቤተ-መጻህፍት" },
  ]

  const toggleLang = () => {
    setLang((prev) => (prev === "EN" ? "አማ" : "EN"))
  }

  return (
    <header className="border-b bg-card/50 backdrop-blur-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Brand */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
              <Sparkles className="w-6 h-6 text-primary-foreground" />
            </div>
            <div>
              <h1 className="text-xl font-black font-montserrat text-foreground">
                SocialSpark
              </h1>
              <p className="text-sm text-muted-foreground">
                {lang === "EN"
                  ? "AI-Powered Content Creation for Ethiopian SMEs"
                  : "ለኢትዮጵያ ቢዝነሶች በAI የተነሳ የይዘት ፈጠራ"}
              </p>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex items-center gap-6 font-medium">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={`hover:text-primary ${
                  pathname === link.href
                    ? "underline underline-offset-4 text-primary font-semibold"
                    : ""
                }`}
              >
                {link.label}
              </Link>
            ))}

            {/* Language toggle */}
            <button
              onClick={toggleLang}
              className="flex items-center gap-1 cursor-pointer"
            >
              <Languages className="w-4 h-4" />
              <span>{lang}</span>
            </button>
          </nav>
        </div>
      </div>
    </header>
  )
}

export default Header

import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  turbopack: {
    root: path.resolve(__dirname),
  },
  images: {
    // Allow images from localhost:9000/videos
    remotePatterns: [
      {
        protocol: "http",
        hostname: "localhost",
        port: "9000",
        pathname: "/videos/**",
      },
    ],
  },
  async rewrites() {
    return [
      {
        source: "/schedule",
        destination: "http://localhost:8000/schedule",
      },
      {
        source: "/generate/:path*",
        destination: "http://localhost:8000/generate/:path*",
      },
      {
        source: "/render/:path*",
        destination: "http://localhost:8000/render/:path*",
      },
      {
        source: "/tasks/:path*",
        destination: "http://localhost:8000/tasks/:path*",
      },
      {
        source: "/export",
        destination: "http://localhost:8000/export",
      },
    ];
  },
};

export default nextConfig;

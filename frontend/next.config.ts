import type { NextConfig } from "next";

// DevSecOps CI/CD Pipeline Configuration
// NEXT CONFIG
const nextConfig: NextConfig = {
  /* config options here */
  output: 'standalone',
  experimental: {
    serverActions: {
      allowedOrigins: [
        'localhost:3000'
      ]
    }
  },
  // Skip type checking during build since we have a separate step for it
  typescript: {
    // Skip type checking during build if SKIP_ENV_VALIDATION is set
    ignoreBuildErrors: process.env.SKIP_ENV_VALIDATION === 'true',
  },
  eslint: {
    // Skip linting during build if SKIP_ENV_VALIDATION is set
    ignoreDuringBuilds: process.env.SKIP_ENV_VALIDATION === 'true',
  }
};

export default nextConfig;

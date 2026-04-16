import { withPayload } from '@payloadcms/next/withPayload'

/** @type {import('next').NextConfig} */
const nextConfig = {
  // Настройка для оптимизации под Docker
  output: 'standalone', 
}

export default withPayload(nextConfig)
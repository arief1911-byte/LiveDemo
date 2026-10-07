import fs from "node:fs";
import path from "node:path";

function firstEnv(...names) {
  for (const name of names) {
    const value = process.env[name];
    if (value && value.trim()) return value.trim();
  }
  return "";
}

const values = {
  SUPABASE_URL: firstEnv("VITE_SUPABASE_URL", "NEXT_PUBLIC_SUPABASE_URL"),
  SUPABASE_ANON_KEY: firstEnv("VITE_SUPABASE_ANON_KEY", "NEXT_PUBLIC_SUPABASE_ANON_KEY"),
  CLOUDINARY_CLOUD_NAME: firstEnv("VITE_CLOUDINARY_CLOUD_NAME", "NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME"),
  CLOUDINARY_UPLOAD_PRESET: firstEnv("VITE_CLOUDINARY_UPLOAD_PRESET", "NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET")
};

const missing = [
  ["VITE_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_URL", values.SUPABASE_URL],
  ["VITE_SUPABASE_ANON_KEY / NEXT_PUBLIC_SUPABASE_ANON_KEY", values.SUPABASE_ANON_KEY],
  ["VITE_CLOUDINARY_CLOUD_NAME / NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME", values.CLOUDINARY_CLOUD_NAME],
  ["VITE_CLOUDINARY_UPLOAD_PRESET / NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET", values.CLOUDINARY_UPLOAD_PRESET]
].filter(([, value]) => !value).map(([name]) => name);

if (missing.length) console.warn("Missing environment variables:", missing.join(", "));

const config = {
  SUPABASE_URL: values.SUPABASE_URL,
  SUPABASE_ANON_KEY: values.SUPABASE_ANON_KEY,
  CLOUDINARY_CLOUD_NAME: values.CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_UPLOAD_PRESET: values.CLOUDINARY_UPLOAD_PRESET
};

fs.mkdirSync("public", { recursive: true });
fs.writeFileSync(
  path.join("public", "config.js"),
  `window.APP_CONFIG = ${JSON.stringify(config, null, 2)};\n`
);

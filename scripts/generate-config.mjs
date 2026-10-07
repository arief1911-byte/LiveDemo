import fs from "node:fs";
import path from "node:path";

const keys = [
  "VITE_SUPABASE_URL",
  "VITE_SUPABASE_ANON_KEY",
  "VITE_CLOUDINARY_CLOUD_NAME",
  "VITE_CLOUDINARY_UPLOAD_PRESET"
];
const values = Object.fromEntries(keys.map(k => [k, process.env[k] || ""]));
const missing = keys.filter(k => !values[k]);
if (missing.length) console.warn("Missing environment variables:", missing.join(", "));

const config = {
  SUPABASE_URL: values.VITE_SUPABASE_URL,
  SUPABASE_ANON_KEY: values.VITE_SUPABASE_ANON_KEY,
  CLOUDINARY_CLOUD_NAME: values.VITE_CLOUDINARY_CLOUD_NAME,
  CLOUDINARY_UPLOAD_PRESET: values.VITE_CLOUDINARY_UPLOAD_PRESET
};

fs.mkdirSync("public", { recursive: true });
fs.writeFileSync(
  path.join("public", "config.js"),
  `window.APP_CONFIG = ${JSON.stringify(config, null, 2)};\n`
);

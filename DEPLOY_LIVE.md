# Deploy Live — Supabase + GitHub + Vercel + Cloudinary

## GitHub
Push this folder to a new repository. The package intentionally excludes `.env`, `node_modules`, employee passwords, and private migration data.

## Supabase
1. Create a new Supabase project.
2. Run `database/schema.sql`.
3. Run `database/rls-policies.sql`.
4. Enable Email/Password under Authentication > Providers.
5. Create users in Authentication > Users.
6. For each user, create a matching row in `public.employees` using the Auth user UUID.

For the first admin, after creating the Auth user, run:
```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where id = 'YOUR-AUTH-USER-UUID';
```
Then create the matching employee row.

## Cloudinary
Create an **Unsigned** upload preset. Record:
- Cloud Name
- Upload Preset name

Never expose the Cloudinary API secret.

## Vercel
Import the GitHub repository and add these Production Environment Variables:
- `VITE_SUPABASE_URL` (recommended), or `NEXT_PUBLIC_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY` (recommended), or `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `VITE_CLOUDINARY_CLOUD_NAME` (recommended), or `NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME`
- `VITE_CLOUDINARY_UPLOAD_PRESET` (recommended), or `NEXT_PUBLIC_CLOUDINARY_UPLOAD_PRESET`

Build command: `npm run build`
Output directory: `dist`

## Supabase Auth redirect
After Vercel gives you a domain, add it under Authentication > URL Configuration > Redirect URLs, e.g.:
`https://your-project.vercel.app/**`

## Local test
Copy `.env.example` to `.env.local`, fill the four values, then:
```bash
npm install
npm run dev
```

The browser-visible Supabase publishable/anon key is not a secret. RLS is the database security boundary.
Never expose a Supabase service-role/secret key or Cloudinary API secret.

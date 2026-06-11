# Product Grid — Channel-wise Illustration Tracker

A shared team tool to track product illustrations channel by channel, with a traffic-light status on every product:

- 🔴 **Red** — not started (every new product starts here)
- 🟡 **Yellow** — started (click the yellow light on the card)
- 🟢 **Green** — set **automatically** when the illustration is uploaded

Features: channels (Amazon, Retail, …), products with range / SKU / notes, image upload with full-size preview, search & channel filter, per-channel progress counts, live sync between teammates, and individual email + password logins.

## Files

| File | What it is |
|---|---|
| `index.html` | The entire app (single file, no build step) |
| `setup.sql` | One-time database setup script for Supabase |

## Setup (one time, ~5 minutes)

1. **Create a Supabase project** at [supabase.com](https://supabase.com) (free plan is fine).
2. **Run the database script**: in the Supabase dashboard open **SQL Editor → New query**, paste the contents of `setup.sql`, and click **Run**.
3. **Get your keys**: dashboard → **Settings → API**. Copy the **Project URL** and the **anon / publishable key**.
4. **Connect the app**: open `index.html` in a text editor, find the `CONFIGURATION` block near the bottom, and replace:
   ```js
   const SUPABASE_URL = "__SUPABASE_URL__";        // e.g. https://abcd1234.supabase.co
   const SUPABASE_ANON_KEY = "__SUPABASE_ANON_KEY__";
   ```
5. **Open `index.html` in a browser**, sign up with your email, confirm via the email link, and log in.

> Tip: ask Claude Code to do steps 2–4 for you — reconnect the Supabase connector to the new account, or paste the Project URL + anon key into the chat.

## Hosting (shareable link for the team)

The app can be served from a **Supabase Edge Function** so teammates just open a URL — no file sharing needed. Ask Claude Code to "deploy the product grid app" once the Supabase project is connected, and it will publish it at:

```
https://<your-project-ref>.supabase.co/functions/v1/app
```

Alternatively, simply send teammates the configured `index.html` file — data still syncs through the shared database.

## Team access

Each teammate clicks **Sign up** on the login screen with their own email + password (one-time email confirmation). Note: anyone with the link can create an account — to restrict access, disable sign-ups in Supabase (**Authentication → Sign In / Up**) after your team has registered.

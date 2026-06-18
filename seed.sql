-- ============================================================
-- RESET / fresh-start script for the BTS FY26-27 dashboard
-- ============================================================
-- The app now seeds all channels and the full framework dataset
-- automatically on first login (when the products table is empty).
--
-- Run this ONLY if you previously loaded the older data structure
-- (channels like "Modern Trade", "MT", "ECom") and want to clear it
-- so the new BTS dashboard can seed itself cleanly.
--
-- WARNING: this deletes ALL products and channels. Uploaded
-- illustrations in storage are not removed by this script.
-- ============================================================

delete from public.products;
delete from public.channels;

-- After running this, just refresh the app and log in — it will
-- recreate the 7 channels (MT — Dmart, MT — Reliance, MT — VMM,
-- General Trade, Ecom — MP, Ecom — OR, Institution) and load all
-- ~130 articles with their ranges, SKUs, print/plain split,
-- fabrics, ideation themes, designers and statuses.

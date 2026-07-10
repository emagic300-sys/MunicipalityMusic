# E & J North Jersey Summer Events Planner

A mobile-first, static local lifestyle guide powered by the supplied 2026 Excel workbook. No backend or framework runtime is required.

## Data profile

The workbook has six sheets: Dashboard, Events, Top Picks, Venues, Town Summary, and Lists & Guide. `EventsTable` on the Events sheet contains 200 records across 25 columns. Import found no blank/malformed records, suspicious date values, or duplicate event keys. Top Picks is derived data and is intentionally not imported again.

Normalized records use stable `id`, local ISO `date`, 24-hour `start`/`end`, event identity/location/category fields, numeric `rating`/`dateNightScore`/`familyScore`, cost, explicit outdoor/weather/chairs/verified booleans, food/parking/notes, source metadata, update value, and an `issues` array. Dates are treated as America/New_York calendar dates and never converted through UTC.

## Use

1. Install dependencies: none. PowerShell 5+ is the only build requirement.
2. Refresh data: `npm run import` if npm is available, or `powershell -ExecutionPolicy Bypass -File scripts/import_events.ps1`.
3. Run locally: open `index.html`, or run `npm run dev` where Python is available.
4. Test: `npm test`, or `powershell -ExecutionPolicy Bypass -File tests/run.ps1`.
5. Build: `npm run build`, or `powershell -ExecutionPolicy Bypass -File scripts/build.ps1`. Output is in `dist/` and a complete ZIP is created at the project root.

## Deploy

- GitHub Pages: publish the contents of `dist/` from a Pages branch or action.
- Netlify: drag the `dist/` folder into Netlify Drop, or set the publish directory to `dist`.
- Vercel: import the repository, use no framework preset, and set the output directory to `dist`.

The app includes live search, filters/chips, six sorts, card/table views, a past-event archive, 10-day calendar, conditional curated rails, event details, Google Maps/Calendar links, and `.ics` downloads.

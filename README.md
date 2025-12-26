# Garden Of Days

This is my personal version of the "One Year: Daily Journal" app on the App Store: https://apps.apple.com/us/app/one-year-daily-journal/id6740510762

Garden Of Days is a lightweight SwiftUI journaling app that encourages a short daily memory entry for every day of the year. It stores entries using SwiftData and includes a companion widget.

## Highlights

- Daily journal entries organized by date
- Year picker and daily grid view for quick navigation
- Widget support (reloads when app becomes active)
- Local daily reminder (scheduled at 10:00 PM) to prompt journaling

## Quick start

1. Open the Xcode workspace: `Garden Of Days.xcworkspace`
2. Select the `Garden Of Days` target and run on a real device or simulator
3. On first launch the app will ask for notification permission; allow it to enable the built-in 10:00 PM reminder

## Notes

- This repository is my implementation inspired by the App Store app linked above and is provided for personal/educational use.
- The notification manager schedules a repeating local notification at 10:00 PM local time. You can edit or disable this behavior in `Managers/NotificationManager.swift`.

## Files of interest

- `Garden Of Days/Managers/NotificationManager.swift` — notification scheduling and permission handling
- `Garden Of Days/Garden_Of_DaysApp.swift` — app entrypoint and notification setup
- `Garden Of Days/Views` — UI views and components

If you'd like, I can add a short CONTRIBUTING guide or screenshots next.

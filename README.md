# Wise Companion

Wise Companion is a macOS **menu bar** app for daily reflection. It shows one calm, original quote per **local calendar day**, and caches it locally.

## Requirements

- macOS 13+
- Xcode 15+

## Run (Xcode)

- Open `WiseCompanion.xcodeproj`
- Select scheme **WiseCompanion**
- Product -> Run (`⌘R`)
- Click the menu bar icon to open the popover

## Run (Terminal, no code signing)

```bash
cd /Users/alex/Sandbox/wise_companion
xcodebuild -project WiseCompanion.xcodeproj -scheme WiseCompanion -configuration Debug -sdk macosx CODE_SIGNING_ALLOWED=NO build
```

Tip: to run the built app, use Xcode: Product -> Show Build Folder in Finder, then open `WiseCompanion.app`.

## Enable quote generation

- Open the app -> Settings
- Add your **OpenAI API key** and save
- Return to the quote view to generate today’s quote

## Security & privacy

- The API key is stored in macOS **Keychain**
- The app avoids logging sensitive data (**no API keys**, **no user prompts** by default)
- Quote cache is stored as a local JSON file under Application Support

## Project docs

- `docs/PRD.md`
- `docs/TECHNICAL_DESIGN.md`
- `docs/IMPLEMENTATION_PLAN.md`
- `docs/TODO.md`
- `docs/QA_CHECKLIST.md`



# ListWheelScrollView Widget Presentation

An alarm-time picker built with three synced `ListWheelScrollView` wheels (hour, minute, AM/PM) and a shared selection highlight.

## Run it

```bash
flutter pub get
flutter run
```

## Key `ListWheelScrollView` attributes

- **`itemExtent`** — fixed height of every row (44px here); required so the wheel can compute scroll offsets without measuring children.
- **`diameterRatio`** — controls how curved the wheel appears; a smaller ratio gives a tighter, more pronounced curl.
- **`perspective`** — adds the 3D vanishing-point effect so rows further from center appear to rotate away from the viewer.

## Screenshot

<img width="1176" height="1971" alt="Screenshot 2026-07-02 102826" src="https://github.com/user-attachments/assets/349e8d7b-bfdf-447a-8443-9e997251feb3" />

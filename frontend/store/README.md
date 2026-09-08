# AgroSense Store & Launch Assets

This directory contains application store listings, descriptions, and icon specifications for the Google Play Store and Android distribution.

## App Identity
- **Application Name**: AgroSense
- **Package ID**: com.example.agrosense_ai
- **Category**: Agriculture & Farming / Productivity
- **Content Rating**: Everyone

## Icon Specifications

### Play Store High-Res Icon
- **Dimensions**: 512 x 512 px
- **Format**: 32-bit PNG (with alpha)
- **Color Palette**: Forest Green (`#2F5D32`), Warm Cream (`#FFF9F0`), Wheat Gold (`#C4A35A`)
- **Visual Design**: Single sprout / crop shoot mark on solid forest-green background. No glossy or skeuomorphic badges.

### Android Adaptive Launcher Icon (API 26+)
- **Foreground Vector**: `res/drawable/ic_launcher_foreground.xml` (108 x 108 dp, safe zone within central 66 dp)
- **Background Color**: `@color/ic_launcher_background` (`#2F5D32`)
- **XML Definition**: `res/mipmap-anydpi-v26/ic_launcher.xml`

### Legacy Raster Icon Densities
| Density | Size (px) | Directory |
|---------|-----------|-----------|
| mdpi    | 48 x 48   | `android/app/src/main/res/mipmap-mdpi/` |
| hdpi    | 72 x 72   | `android/app/src/main/res/mipmap-hdpi/` |
| xhdpi   | 96 x 96   | `android/app/src/main/res/mipmap-xhdpi/` |
| xxhdpi  | 144 x 144 | `android/app/src/main/res/mipmap-xxhdpi/` |
| xxxhdpi | 192 x 192 | `android/app/src/main/res/mipmap-xxxhdpi/` |

### Play Store Feature Graphic
- **Dimensions**: 1024 x 500 px
- **Format**: JPEG or 24-bit PNG (no alpha)
- **Design Guidance**: Warm sunlight farm field hero with AgroSense wordmark in Fraunces serif typeface and wheat accent.

## Store Listing Files
- `listing_en.md` - English Play Store short and full descriptions
- `listing_hi.md` - Hindi (हिंदी) Play Store descriptions
- `listing_mr.md` - Marathi (मराठी) Play Store descriptions
- `screenshot_captions.md` - Screenshot capture plan and localized captions

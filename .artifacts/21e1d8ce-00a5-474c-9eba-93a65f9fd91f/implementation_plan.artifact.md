# Implementation Plan - Contact Page and UI Refinement

This plan focuses on adding a contact page, improving the currency list UI by reusing the `PriceCard` widget, adding USDT support, and refactoring the API service for better clarity.

## User Review Required

> [!NOTE]
> I will add the `url_launcher` package to make the Telegram link clickable. This requires a `flutter pub get`.

## Proposed Changes

### Dependencies & Services

#### [MODIFY] [pubspec.yaml](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/pubspec.yaml)
Add `url_launcher: ^6.3.0` to dependencies.

#### [RENAME] `lib/services/gold_api.dart` -> [market_api.dart](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/lib/services/market_api.dart)
Rename the file and class to `MarketApi` to reflect its broader scope.
Update `fetchCurrencies` to include `USDT` in the `sembol` parameter.

---

### UI & Screens

#### [NEW] [contact_screen.dart](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/lib/screens/contact_screen.dart)
Implement the contact page with Sarraf Gold branding and a functional Telegram link using `url_launcher`.

#### [MODIFY] [home_screen.dart](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/lib/screens/home_screen.dart)
Update the `BottomNavigationBar` to include the "İletişim" tab.

#### [MODIFY] [currency_screen.dart](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/lib/screens/currency_screen.dart)
Refactor to use the `PriceCard` widget, ensuring consistent styling (colors, arrows, and change percentages) with the Gold screen.

#### [MODIFY] [gold_screen.dart](file:///C:/Users/Mahyar/StudioProjects/gold_tracker/gold_tracker/lib/screens/gold_screen.dart)
Update imports to use `MarketApi`.

## Verification Plan

### Automated Tests
- Run `flutter analyze` to verify imports and syntax.

### Manual Verification
1. **Navigation**: Verify the new "İletişim" tab appears and works.
2. **Contact Page**: Verify the Telegram link opens the Telegram app or browser.
3. **Currency List**: Verify it now looks identical in style to the Gold list (with arrows and colors).
4. **Tether (USDT)**: Verify USDT prices are visible in the Döviz tab.

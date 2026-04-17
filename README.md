# CalorieTrack Flutter

A local-only mobile app that combines calorie tracking with a small
Glovo-style food-ordering simulation, built with Flutter and SQLite.
Written for a bachelor thesis — folder layout is deliberately small
and boring.

## Features

### Accounts & wallet
- Username + password registration and login (salted SHA-256).
- Every account starts with a 200 lei wallet balance used for orders.
- Change password from the profile screen.

### Calorie tracker
- Per-user meal CRUD with full macros (calories, protein, carbs, fat,
  fiber, sugar).
- Daily totals card on the main screen and a meal-history screen.
- USDA-backed food lookup (optional; falls back to local cache if no
  API key is configured).

### Food ordering simulation (Glovo-like)
- `Foods` discover screen with debounced search across restaurants and
  menu items.
- Restaurant menu screen grouped by category, with delivery fee and
  estimated time pills.
- Tap an item → popup with description/price → `Add to order`.
- Floating "Complete order" bar appears when the cart has items.
- Checkout screen with quantity +/- controls, subtotal, delivery,
  total, and a live wallet-balance warning.
- Placing an order atomically deducts funds and persists the order,
  then automatically logs each item to the calorie tracker as a meal
  for today (macros × quantity).
- Order history screen with per-line macro summaries.

### Foundations
- Local persistence with SQLite (`sqflite`); schema migrations are
  additive and idempotent.
- `ON DELETE CASCADE` between users and their meals/orders; every
  query filters by `user_id`.
- Reactive UI driven by `ValueNotifier` in repositories and
  `ChangeNotifier` in controllers — no external state-management
  libraries.
- Centralised design system (tokens + theme + reusable widgets).
- Single `AppException` error type surfaced to the UI via snackbars.

> **Scope note:** local-only. There is no backend, no real ordering,
> no multi-device sync. Orders are simulated wallet transactions.

## Project layout

```
lib/
├── main.dart                         # bootstrap
├── core/
│   ├── app.dart                      # MaterialApp + theme
│   ├── config.dart                   # .env loader (USDA key)
│   └── service_locator.dart          # composition root (late-final globals)
├── database/
│   └── database.dart                 # AppDatabase + table/column constants
├── exceptions/
│   └── app_exception.dart            # one exception type, one field
├── utils/
│   ├── password_hasher.dart          # salted SHA-256
│   └── money_formatter.dart          # shared "X lei" formatter
├── design/                           # design system
│   ├── app_theme.dart
│   ├── design.dart                   # barrel export
│   ├── tokens/
│   │   ├── app_colors.dart           # incl. success / accent / surfaces
│   │   ├── app_radii.dart            # all4, all8, all12, pill
│   │   ├── app_spacing.dart
│   │   └── app_typography.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_scaffold.dart
│       └── app_text_field.dart
└── features/
    ├── auth/
    │   ├── entities/user.dart
    │   ├── services/{auth_repository,auth_controller,auth_validators}.dart
    │   └── screens/{login_screen,register_screen}.dart
    ├── profile/
    │   └── screens/{profile_screen,change_password_screen}.dart
    ├── meals/
    │   ├── entities/{meal,meal_type}.dart
    │   ├── services/{meal_repository,meals_controller}.dart
    │   └── screens/
    │       ├── main_screen.dart
    │       ├── create_meal_screen.dart
    │       ├── update_meal_screen.dart
    │       ├── meal_details_screen.dart
    │       ├── meal_history_screen.dart
    │       ├── meal_item.dart
    │       ├── meal_form_fields.dart
    │       └── date_format.dart
    ├── foods/
    │   ├── entities/{food,food_data_type,food_source}.dart
    │   ├── services/
    │   │   ├── food_repository.dart         # local cache (sqflite)
    │   │   ├── food_search_ranker.dart
    │   │   └── usda_nutrition_service.dart  # optional USDA API
    │   └── screens/food_search_screen.dart
    ├── restaurants/
    │   ├── entities/{restaurant,menu_item}.dart
    │   ├── services/{restaurant_repository,restaurant_seeder}.dart
    │   └── screens/{discover_screen,restaurant_menu_screen}.dart
    └── orders/
        ├── entities/order.dart
        ├── services/{order_repository,cart_controller}.dart
        ├── widgets/{cart_complete_bar,menu_item_popup}.dart
        └── screens/{checkout_screen,order_history_screen}.dart
```

Each feature keeps three folders: `entities/`, `services/`, `screens/`
(plus `widgets/` when a feature has shared pieces). Screen-only helper
widgets live next to the screens that use them.

### How the pieces fit

```
screen ──▶ controller (ChangeNotifier) ──▶ repository ──▶ sqflite
```

- **Repository** owns persistence and the in-memory list/user. Exposes a
  `ValueListenable` so UI updates without streams or state-management
  libs. Throws `AppException` for domain errors.
- **Controller** wraps the repository with UI concerns (loading flag,
  error message) and forwards change notifications.
- **Screen** reads the controller's state and calls its methods. Screens
  never touch `sqflite` directly.
- **Seeders** (e.g. `RestaurantSeeder`) populate initial data
  idempotently — they no-op when the table already has rows.
- All wiring lives in `service_locator.dart` as plain `late final`
  globals.

### Cart / checkout flow

```
DiscoverScreen ──▶ RestaurantMenuScreen ──▶ MenuItemPopup
                            │                    │
                            ▼                    ▼
                      CartCompleteBar ◀──── CartController (ChangeNotifier)
                            │
                            ▼
                      CheckoutScreen ──▶ OrderRepository.placeOrder()
                                              │      (txn: orders + items)
                                              ▼
                                         AuthRepository.adjustBalance(-total)
                                              │
                                              ▼
                                         MealsController.add(...)  # per line
```

`CartController` is session-scoped (not persisted) and holds at most
one restaurant at a time — adding an item from a different restaurant
prompts to clear the cart first.

### SOLID, briefly

| Principle | Applied as |
|---|---|
| Single Responsibility | `AppDatabase` opens the DB. Each repository owns its tables and cache. Controllers only bridge UI ↔ repository. The design system owns styling. The money formatter lives in one place. |
| Open / Closed | Adding a feature is adding a folder under `features/`; existing ones are untouched. Database migrations are additive (`CREATE TABLE IF NOT EXISTS`, `_addColumnIfMissing`). |
| Dependency Inversion | Controllers and screens depend on repository classes; the database and collaborators are injected through constructors, not looked up inside. |

(LSP and ISP aren't really exercised here — there's one implementation
of each repository and it stays that way. Keeping a parallel interface
for every class would be ceremony, not design.)

### Error model

Repositories throw a single `AppException` with a human-readable
message (`Not enough funds…`, `Username already taken`, etc.).
Controllers catch it and expose `errorMessage` to screens; screens show
it in a snackbar. Unexpected errors are caught generically and surfaced
the same way.

### Database migrations

`AppDatabase._version` is bumped every time the schema changes.
`onUpgrade` applies `CREATE TABLE IF NOT EXISTS` and
`_addColumnIfMissing(...)` so that older installations catch up without
losing data. `placeOrder` uses a single transaction to insert the
order row and its items atomically.

## Getting started

```powershell
flutter pub get
flutter run
```

### Optional: USDA food lookup

The food search feature can pull nutrition data from the USDA
FoodData Central API. Without a key it falls back to local data.

1. Copy `.env.example` → `.env`.
2. Replace `DEMO_KEY` with your key from
   https://fdc.nal.usda.gov/api-key-signup.html.

### Static analysis

```powershell
dart analyze
```

## How to use

1. **Register** an account on first launch — you start with 200 lei.
2. **Main screen** — track meals, see daily totals, add manually via
   the bottom "Add meal" bar or browse the Foods tab.
3. **Foods** — search restaurants or dishes, open a restaurant to see
   its categorised menu, add items to the cart.
4. **Checkout** — tap the green "Complete order" bar, review
   quantities/total, and press "Order" to deduct the funds and log
   the items into the calorie tracker automatically.
5. **Profile** (top-left icon) — view balance, open order history,
   change password, or log out.

## Security notes

- Each user gets a random 16-byte salt; passwords are stored as
  `SHA-256(salt:password)` in base64.
- `PRAGMA foreign_keys = ON` enforces `ON DELETE CASCADE` between
  users and their meals and orders.
- Every per-user query includes `WHERE user_id = ?`, so user A
  literally cannot read or modify user B's data even by guessing an id.
- `.env` is git-ignored; `.env.example` is the only committed template.

## Possible future enhancements

- AI-powered meal suggestions on the Foods screen (button is wired
  but currently shows a "coming soon" snackbar).
- Date picker on the create-meal screen (currently always
  `DateTime.now()`).
- Real payment / delivery integration (today it's a simulated wallet).
- Daily / weekly summaries, filtering, CSV export.
- Multi-device sync via a real backend.

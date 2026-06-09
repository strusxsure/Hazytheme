# 🌫️ HazyTheme for Pterodactyl

An ultra-modern, glassmorphism-based theme for Pterodactyl.

## ✨ Features
*   **Glassmorphism UI:** Translucent panels with backdrop blur.
*   **Modern Sidebar:** Collapsible sidebar with high-quality icons.
*   **Animated Orbs:** Ambient background animations.
*   **Admin Management:** Built-in settings page in the Pterodactyl Admin area.
*   **Dynamic Customization:** Change colors and toggle features without editing code.

## 🛠️ Admin Panel Management
You can manage HazyTheme settings directly from your Pterodactyl Admin panel:
1. Go to **Admin Panel** > **Settings** > **HazyTheme**.
2. From there you can:
   *   Change the **Primary Accent Color**.
   *   Toggle **Background Animations** (Ambient Orbs).
   *   Toggle **Sidebar Power Buttons** (Quick actions).
   *   Switch between **Dark** and **Light** modes.

---

## 🚀 Installation (Live VPS)

1. **Upload Files:**
   Upload the theme files to your Pterodactyl directory (usually `/var/www/pterodactyl`).

2. **Run Installation Script:**
   ```bash
   bash install-hazytheme.sh
   ```

3. **Manual Steps (If script fails):**
   ```bash
   yarn install
   yarn build:production
   php artisan view:clear
   php artisan config:clear
   ```

---

## 🏗️ Sandbox Installation (CodeSandbox/Testing)

If you are testing in a restricted environment:

1. **Run the Super One-Liner:**
   ```bash
   bash install-hazytheme.sh && php artisan serve --port=8080
   ```

2. **Access the Panel:**
   Open the port 8080 preview.

---

## 📂 Manual Code Integration
If you prefer manual installation, ensure these files are updated:
*   **Routes:** `routes/admin.php` must include HazyTheme settings routes.
*   **Composer:** `app/Http/ViewComposers/AssetComposer.php` must inject `hazytheme` settings.
*   **App:** `resources/scripts/components/App.tsx` must handle the dynamic styles.
*   **Sidebar:** `resources/scripts/routers/DashboardRouter.tsx` & `ServerRouter.tsx` must import `HazySidebar` and `HazyNavbar`.

---

## ❓ Troubleshooting

*   **Changes not appearing?**
    Run `php artisan view:clear` and refresh your browser cache (Ctrl+F5).
*   **Build error?**
    Ensure you are using Node.js 16+ (preferably 20) and have run `yarn install`.
*   **Admin tab missing?**
    Check that `resources/views/partials/admin/settings/nav.blade.php` was updated.

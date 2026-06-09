# 🌫️ HazyTheme for Pterodactyl

HazyTheme is a premium-feel, glassmorphism-based theme for the Pterodactyl Panel. It features a modern sidebar layout, collapsible navigation, and real-time circular resource graphs.

---

## 📋 Prerequisites

Before installing, ensure your server meets these requirements:
- **Node.js:** 20.x or 22.x
- **Yarn:** Latest version (`npm install --global yarn`)
- **Pterodactyl Panel:** 1.11.x or newer (recommended)

---

## 🚀 Installation (Live VPS / Production)

If you are installing this on your live server, follow these steps in order:

### 1. Upload & Extract
Upload the `hazytheme.zip` to your panel's root directory (usually `/var/www/pterodactyl`).
```bash
cd /var/www/pterodactyl
unzip -o hazytheme.zip
chown -R www-data:www-data *
```

### 2. Install Theme Dependencies
This theme requires specific packages for icons and graphs.
```bash
yarn add lucide-react react-circular-progressbar
```

### 3. Build the Production Assets (CRITICAL)
**If you skip this step, the theme will NOT appear.** This compiles the React code.
```bash
yarn build:production
```

### 4. Clear the Cache
```bash
php artisan view:clear
php artisan config:clear
php artisan optimize
```

---

## 🧪 Installation (CodeSandbox / Testing)

For testing in CodeSandbox, use the provided helper script:

1. Open the terminal in CodeSandbox.
2. Run the script:
   ```bash
   chmod +x install-hazytheme.sh
   ./install-hazytheme.sh
   ```
3. Start the preview:
   ```bash
   php artisan serve --port=8080
   ```

---

## ❌ Troubleshooting (Changes not showing?)

If you installed the theme but the panel still looks old:

1. **Did the Build Finish?**
   Check the output of `yarn build:production`. It should say "Success" and show a list of generated files. If it fails with "Command not found", you need to install Node/Yarn.

2. **Clear Browser Cache:**
   Your browser often saves the old panel files. Press `CTRL + F5` to force a hard refresh.

3. **Check File Paths:**
   Ensure `resources/scripts/routers/DashboardRouter.tsx` was actually replaced. Open the file and look for `import HazySidebar from '@/components/hazy/HazySidebar';`.

4. **Storage Permissions:**
   Ensure the `storage` folder is writable so Laravel can clear the view cache.
   ```bash
   chmod -R 777 storage/framework/views
   ```

---

## ✨ Features
- **Sidebar Layout:** A clean, modern navigation bar on the left.
- **Glassmorphism:** Elegant transparency and blur effects.
- **Collapsible Menu:** Save screen space with a toggleable sidebar.
- **Circular Graphs:** Beautiful CPU and Memory usage visualizations.

## 📝 Credits
Built with ❤️ for the Pterodactyl Community.

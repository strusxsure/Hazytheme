#!/bin/bash
echo "🌫️ Preparing HazyTheme for CodeSandbox..."

# 1. Setup Environment
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env 2>/dev/null || echo "APP_KEY=" > .env
fi

# 2. Setup Storage
mkdir -p storage/framework/{sessions,views,cache}
chmod -R 777 storage

# 3. Install PHP Dependencies (Ignore missing extensions in Sandbox)
composer install --ignore-platform-reqs

# 4. Generate Key
php artisan key:generate --force

# 5. Install JS Dependencies (Allow Node 20)
yarn install --ignore-engines

# 6. Build Theme
echo "Building theme assets (this may take a few minutes)..."
yarn build:production

# 7. Clear Cache
php artisan view:clear
php artisan config:clear
php artisan cache:clear
php artisan optimize

echo "✅ HazyTheme installed and built!"
echo "You can now run 'php artisan serve --port=8080' to see the panel."

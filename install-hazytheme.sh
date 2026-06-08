#!/bin/bash
echo "🌫️ Installing HazyTheme..."
yarn install && yarn build:production
php artisan view:clear && php artisan config:clear && php artisan cache:clear && php artisan optimize
echo "✅ HazyTheme installed!"

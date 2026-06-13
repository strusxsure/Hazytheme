#!/bin/bash
set -e
echo "🌫️ HazyTheme ULTRA v2.1 - Safety First Edition"

if [ ! -f artisan ]; then
    echo "❌ Error: Run this in /var/www/pterodactyl"
    exit 1
fi
# 1. Directories
mkdir -p resources/scripts/components/hazy/elements resources/scripts/css app/Http/Controllers/Admin/Settings resources/views/admin/settings

# 2. Writing Theme Files
echo "✍️ Writing theme source files..."

cat > resources/scripts/css/hazytheme.css <<'FILE'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap');
:root { --hazy-primary: #a78bfa; --hazy-bg: #0b0f1a; --hazy-text: #f8fafc; --hazy-glass-border: rgba(255, 255, 255, 0.08); }
body { background-color: var(--hazy-bg) !important; color: var(--hazy-text) !important; font-family: 'Inter', sans-serif !important; overflow-x: hidden; min-height: 100vh; }
.glass { background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(16px); border: 1px solid var(--hazy-glass-border); }
.glass-heavy { background: rgba(11, 15, 26, 0.7); backdrop-filter: blur(32px); border: 1px solid var(--hazy-glass-border); }
.animate-fade-up { animation: fade-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
@keyframes fade-up { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
.hazy-orb-1, .hazy-orb-2, .hazy-orb-3 { position: fixed; border-radius: 50%; filter: blur(100px); z-index: -1; opacity: 0.4; pointer-events: none; }
.hazy-orb-1 { width: 800px; height: 800px; background: radial-gradient(circle, var(--hazy-primary) 0%, transparent 70%); top: -300px; right: -300px; }
.hazy-orb-2 { width: 900px; height: 900px; background: radial-gradient(circle, #4f46e5 0%, transparent 70%); bottom: -400px; left: -400px; }
.hazy-orb-3 { width: 500px; height: 500px; background: radial-gradient(circle, #0ea5e9 0%, transparent 70%); top: 30%; left: 5%; }
div[class*="PageContentBlock"] { background: transparent !important; }
div[class*="ContentContainer"] { max-width: 1600px !important; padding: 2rem !important; }
FILE

cat > app/Http/Controllers/Admin/Settings/HazyThemeController.php <<'FILE'
<?php
namespace Pterodactyl\Http\Controllers\Admin\Settings;
use Illuminate\View\View;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
class HazyThemeController extends Controller {
    public function __construct(private AlertsMessageBag $alert, private SettingsRepositoryInterface $settings) {}
    public function index(): View {
        return view('admin.settings.hazytheme', [
            'hazy_primary' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
            'hazy_animation' => $this->settings->get('hazytheme::animation', 'true'),
            'hazy_sidebar_power' => $this->settings->get('hazytheme::sidebar_power', 'true'),
            'hazy_dark_mode' => $this->settings->get('hazytheme::dark_mode', 'true'),
        ]);
    }
    public function update(Request $request): RedirectResponse {
        $this->settings->set('hazytheme::primary_color', $request->input('hazytheme::primary_color'));
        $this->settings->set('hazytheme::animation', $request->input('hazytheme::animation'));
        $this->settings->set('hazytheme::sidebar_power', $request->input('hazytheme::sidebar_power'));
        $this->settings->set('hazytheme::dark_mode', $request->input('hazytheme::dark_mode'));
        $this->alert->success('HazyTheme settings updated.')->flash();
        return redirect()->route('admin.settings.hazytheme');
    }
}
FILE

cat > resources/views/admin/settings/hazytheme.blade.php <<'FILE'
@extends('layouts.admin')
@include('partials/admin.settings.nav', ['activeTab' => 'hazytheme'])
@section('title') HazyTheme Settings @endsection
@section('content')
    @yield('settings::nav')
    <div class="row"><div class="col-xs-12"><div class="box"><div class="box-header with-border"><h3 class="box-title">Theme Configuration</h3></div>
                <form action="{{ route('admin.settings.hazytheme') }}" method="POST">
                    <div class="box-body"><div class="row">
                            <div class="form-group col-md-4"><label class="control-label">Primary Color</label><div><input type="color" class="form-control" name="hazytheme::primary_color" value="{{ old('hazytheme::primary_color', $hazy_primary) }}" /></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Animations</label><div><select name="hazytheme::animation" class="form-control"><option value="true" @if($hazy_animation === 'true') selected @endif>Enabled</option><option value="false" @if($hazy_animation === 'false') selected @endif>Disabled</option></select></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Power Buttons</label><div><select name="hazytheme::sidebar_power" class="form-control"><option value="true" @if($hazy_sidebar_power === 'true') selected @endif>Enabled</option><option value="false" @if($hazy_sidebar_power === 'false') selected @endif>Disabled</option></select></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Theme Mode</label><div><select name="hazytheme::dark_mode" class="form-control"><option value="true" @if($hazy_dark_mode === 'true') selected @endif>Dark</option><option value="false" @if($hazy_dark_mode === 'false') selected @endif>Light</option></select></div></div>
                        </div></div>
                    <div class="box-footer">{!! csrf_field() !!}<button type="submit" class="btn btn-sm btn-primary pull-right">Save Settings</button></div>
                </form>
            </div></div></div>
@endsection
FILE

# 3. React Components
echo "⚛️ Creating Hazy UI Components..."

cat > resources/scripts/components/hazy/elements/HazyBackgroundOrbs.tsx <<'FILE'
import React from 'react';
import { useStoreState } from 'easy-peasy';
const HazyBackgroundOrbs = () => {
    const isAnimated = useStoreState((state: any) => state.settings.data?.hazytheme?.animation !== 'false');
    if (!isAnimated) return null;
    return (
        <div className="fixed inset-0 pointer-events-none -z-10 overflow-hidden">
            <div className="hazy-orb-1" />
            <div className="hazy-orb-2" />
            <div className="hazy-orb-3" />
        </div>
    );
};
export default HazyBackgroundOrbs;
FILE

cat > resources/scripts/components/hazy/elements/HazyResourceGraph.tsx <<'FILE'
import React from 'react';
import { CircularProgressbar, buildStyles } from 'react-circular-progressbar';
import 'react-circular-progressbar/dist/styles.css';
interface Props { value: number; max: number; label: string; color: string; }
const HazyResourceGraph = ({ value, max, label, color }: Props) => {
    const percentage = Math.min(100, Math.round((value / (max || 1)) * 100));
    return (
        <div className="w-24 h-24 flex flex-col items-center justify-center p-2 glass rounded-2xl">
            <CircularProgressbar value={percentage} text={`${percentage}%`} styles={buildStyles({
                pathColor: color, textColor: '#fff', trailColor: 'rgba(255,255,255,0.05)', textSize: '22px'
            })} />
            <span className="text-[10px] uppercase font-bold mt-2 opacity-50">{label}</span>
        </div>
    );
};
export default HazyResourceGraph;
FILE

# 4. Patching logic (SAFE EDITION)
echo "🛡️ Patching core files (Non-destructive)..."

# Patch AssetComposer.php
if ! grep -q "hazytheme" app/Http/ViewComposers/AssetComposer.php; then
    sed -i "/'name' => config('app.name', 'Pterodactyl'),/a \                'hazytheme' => [\n                    'primary_color' => \$this->settings->get('hazytheme::primary_color', '#6366f1'),\n                    'animation' => \$this->settings->get('hazytheme::animation', 'true'),\n                    'sidebar_power' => \$this->settings->get('hazytheme::sidebar_power', 'true'),\n                ]," app/Http/ViewComposers/AssetComposer.php
fi

# Patch App.tsx for Hazy Orbs and CSS
if ! grep -q "HazyBackgroundOrbs" resources/scripts/components/App.tsx; then
    sed -i "/import React, { useEffect } from 'react';/a import HazyBackgroundOrbs from '@/components/hazy/elements/HazyBackgroundOrbs';" resources/scripts/components/App.tsx
    sed -i "/import { StoreProvider } from 'easy-peasy';/a import '@/css/hazytheme.css';" resources/scripts/components/App.tsx
import { useStoreState } from 'easy-peasy';
    sed -i "/<GlobalStylesheet \/>/a \                    <HazyBackgroundOrbs />" resources/scripts/components/App.tsx
fi

# Inject primary color CSS variable in App.tsx
if ! grep -q "setProperty('--hazy-primary'" resources/scripts/components/App.tsx; then
    sed -i "/const App = () => {/a \    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');\n    useEffect(() => {\n        document.documentElement.style.setProperty('--hazy-primary', primaryColor);\n    }, [primaryColor]);" resources/scripts/components/App.tsx
fi

# Patch routes
if ! grep -q "hazytheme" routes/admin.php; then
    echo "Route::group(['prefix' => 'settings'], function () { Route::get('/hazytheme', [Pterodactyl\Http\Controllers\Admin\Settings\HazyThemeController::class, 'index'])->name('admin.settings.hazytheme'); Route::post('/hazytheme', [Pterodactyl\Http\Controllers\Admin\Settings\HazyThemeController::class, 'update']); });" >> routes/admin.php
fi

# 5. Dependency Injection
echo "📦 Injecting dependencies..."
sed -i '/"dependencies": {/a \    "lucide-react": "^0.263.1",\n    "react-circular-progressbar": "^2.1.0",' package.json

# 6. Build & Cleanup
echo "🚀 Running production build..."
npm install --production=false
npm run build:production

echo "🧹 Clearing cache..."
php artisan view:clear
php artisan config:clear

echo "✅ HazyTheme ULTRA v2.1 Installed Successfully!"
echo "📍 Go to Admin > Settings > HazyTheme to customize."

echo "🖥️ Overhauling Dashboard and Console..."

# Create Custom Hazy Components
cat > resources/scripts/components/hazy/HazyDashboard.tsx <<'FILE'
import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import getServers from '@/api/getServers';
import ServerRow from '@/components/dashboard/ServerRow';
import Pagination from '@/components/elements/Pagination';
import { useStoreState } from 'easy-peasy';
import { PaginatedResult } from '@/api/http';
import { useLocation } from 'react-router-dom';
import PageContentBlock from '@/components/elements/PageContentBlock';
import tw from 'twin.macro';

export default () => {
    const { search } = useLocation();
    const [ servers, setServers ] = useState<PaginatedResult<Server>>();
    const showOnlyAdmin = useStoreState((state: any) => state.settings.data?.hazytheme?.show_admin === 'true');

    useEffect(() => {
        getServers({ query: search, admin: showOnlyAdmin }).then(setServers);
    }, [ search ]);

    return (
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fade-up">
                {!servers ? (
                    <div className="col-span-full flex justify-center py-20"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-white"></div></div>
                ) : (
                    servers.data.map((server, index) => (
                        <div key={server.uuid} className="glass rounded-3xl p-1 transition-transform hover:scale-[1.02] duration-300">
                             <ServerRow server={server} className="!bg-transparent !border-0" />
                        </div>
                    ))
                )}
            </div>
            {servers && <Pagination data={servers} onPageSelect={(page) => {}} />}
        </PageContentBlock>
    );
};
FILE

# Patch DashboardRouter to use HazyDashboard
if ! grep -q "HazyDashboard" resources/scripts/routers/DashboardRouter.tsx; then
    sed -i "/import DashboardContainer from '@/components/dashboard/DashboardContainer';/a import HazyDashboard from '@/components/hazy/HazyDashboard';" resources/scripts/routers/DashboardRouter.tsx
    sed -i "s/<DashboardContainer \/>/<HazyDashboard \/>/g" resources/scripts/routers/DashboardRouter.tsx
fi

# Patch Global Stylesheet for transparency
sed -i "s/background-color: var(--hazy-bg);/background-color: transparent !important;/g" resources/scripts/assets/css/GlobalStylesheet.ts 2>/dev/null || true


# Patch Console for 7xl width
echo "📺 Expanding Console view..."
if [ -f resources/scripts/components/server/console/ConsoleContainer.tsx ]; then
    sed -i "s/max-w-6xl/max-w-[100rem]/g" resources/scripts/components/server/console/ConsoleContainer.tsx
    sed -i "s/max-w-7xl/max-w-[100rem]/g" resources/scripts/components/server/console/ConsoleContainer.tsx
fi

# Finalizing the UI with custom CSS variables injection in App.tsx
if ! grep -q "useEffect(() => {" resources/scripts/components/App.tsx; then
    sed -i "/const App = () => {/a \    const hazy = useStoreState((state: any) => state.settings.data?.hazytheme);\n    useEffect(() => {\n        if (hazy?.primary_color) document.documentElement.style.setProperty('--hazy-primary', hazy.primary_color);\n    }, [hazy]);" resources/scripts/components/App.tsx
fi


# Patch Sidebar for glass effect
echo "📂 Applying glass effect to Sidebar..."
if [ -f resources/scripts/components/NavigationBar.tsx ]; then
    sed -i "s/bg-neutral-900/glass-heavy/g" resources/scripts/components/NavigationBar.tsx
    sed -i "s/bg-neutral-700/bg-white\/5/g" resources/scripts/components/NavigationBar.tsx
fi

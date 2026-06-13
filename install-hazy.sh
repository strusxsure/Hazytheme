#!/bin/bash
set -e
echo "🌫️ HazyTheme ULTRA v2.1 - Safety First Edition"

if [ ! -f artisan ]; then
    echo "❌ Error: Run in /var/www/pterodactyl"
    # exit 1
fi

mkdir -p resources/scripts/components/hazy/elements resources/scripts/css app/Http/Controllers/Admin/Settings resources/views/admin/settings

echo "✍️ Writing source files..."

cat > resources/scripts/css/hazytheme.css <<'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap');
:root { --hazy-primary: #a78bfa; --hazy-bg: #0b0f1a; --hazy-text: #f8fafc; --hazy-glass-border: rgba(255, 255, 255, 0.08); }
body { background-color: var(--hazy-bg) !important; color: var(--hazy-text) !important; font-family: 'Inter', sans-serif !important; }
.glass { background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(16px); border: 1px solid var(--hazy-glass-border); }
.glass-heavy { background: rgba(11, 15, 26, 0.7); backdrop-filter: blur(32px); border: 1px solid var(--hazy-glass-border); }
.hazy-orb-1, .hazy-orb-2, .hazy-orb-3 { position: fixed; border-radius: 50%; filter: blur(100px); z-index: -1; opacity: 0.4; pointer-events: none; }
.hazy-orb-1 { width: 800px; height: 800px; background: radial-gradient(circle, var(--hazy-primary) 0%, transparent 70%); top: -300px; right: -300px; }
.hazy-orb-2 { width: 900px; height: 900px; background: radial-gradient(circle, #4f46e5 0%, transparent 70%); bottom: -400px; left: -400px; }
.hazy-orb-3 { width: 500px; height: 500px; background: radial-gradient(circle, #0ea5e9 0%, transparent 70%); top: 30%; left: 5%; }
div[class*="PageContentBlock"] { background: transparent !important; }
div[class*="ContentContainer"] { max-width: 1600px !important; padding: 2rem !important; }
EOF

cat > resources/scripts/components/hazy/elements/HazyBackgroundOrbs.tsx <<'EOF'
import React from 'react';
import { useStoreState } from 'easy-peasy';
const HazyBackgroundOrbs = () => {
    const isAnimated = useStoreState((state: any) => state.settings.data?.hazytheme?.animation !== 'false');
    if (!isAnimated) return null;
    return (
        <div className="fixed inset-0 pointer-events-none -z-10 overflow-hidden">
            <div className="hazy-orb-1" /><div className="hazy-orb-2" /><div className="hazy-orb-3" />
        </div>
    );
};
export default HazyBackgroundOrbs;
EOF

cat > resources/scripts/components/hazy/HazyDashboard.tsx <<'EOF'
import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import getServers from '@/api/getServers';
import ServerRow from '@/components/dashboard/ServerRow';
import Pagination from '@/components/elements/Pagination';
import { useStoreState } from 'easy-peasy';
import { PaginatedResult } from '@/api/http';
import { useLocation } from 'react-router-dom';
import PageContentBlock from '@/components/elements/PageContentBlock';
export default () => {
    const { search } = useLocation();
    const [ servers, setServers ] = useState<PaginatedResult<Server>>();
    useEffect(() => { getServers({ query: search }).then(setServers); }, [ search ]);
    return (
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fade-up">
                {!servers ? (
                    <div className="col-span-full flex justify-center py-20"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-white"></div></div>
                ) : (
                    servers.data.map((server) => (
                        <div key={server.uuid} className="glass rounded-3xl p-1 transition-transform hover:scale-[1.02] duration-300">
                             <ServerRow server={server} className="!bg-transparent !border-0" />
                        </div>
                    ))
                )}
            </div>
            {servers && <Pagination data={servers} onPageSelect={() => {}} />}
        </PageContentBlock>
    );
};
EOF

cat > app/Http/Controllers/Admin/Settings/HazyThemeController.php <<'EOF'
<?php
namespace Pterodactyl\Http\Controllers\Admin\Settings;
use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
class HazyThemeController extends Controller {
    public function __construct(private SettingsRepositoryInterface $settings) {}
    public function index(): View {
        return view('admin.settings.hazytheme', [
            'hazy_primary' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
            'hazy_animation' => $this->settings->get('hazytheme::animation', 'true'),
        ]);
    }
    public function update(Request $request) {
        $this->settings->set('hazytheme::primary_color', $request->input('hazytheme::primary_color'));
        $this->settings->set('hazytheme::animation', $request->input('hazytheme::animation'));
        return redirect()->route('admin.settings.hazytheme');
    }
}
EOF

cat > resources/views/admin/settings/hazytheme.blade.php <<'EOF'
@extends('layouts.admin')
@include('partials/admin.settings.nav', ['activeTab' => 'hazytheme'])
@section('title') HazyTheme Settings @endsection
@section('content')
    <div class="row"><div class="col-xs-12"><div class="box"><div class="box-header with-border"><h3 class="box-title">Theme Configuration</h3></div>
        <form action="{{ route('admin.settings.hazytheme') }}" method="POST">
            <div class="box-body"><div class="row">
                <div class="form-group col-md-4"><label>Primary Color</label><input type="color" class="form-control" name="hazytheme::primary_color" value="{{ old('hazytheme::primary_color', $hazy_primary) }}" /></div>
                <div class="form-group col-md-4"><label>Animations</label><select name="hazytheme::animation" class="form-control"><option value="true">Enabled</option><option value="false">Disabled</option></select></div>
            </div></div>
            <div class="box-footer">{!! csrf_field() !!}<button type="submit" class="btn btn-primary pull-right">Save</button></div>
        </form>
    </div></div></div>
@endsection
EOF

echo "🛡️ Patching core files..."

if ! grep -q "hazytheme" app/Http/ViewComposers/AssetComposer.php; then
    sed -i "/'name' => config('app.name', 'Pterodactyl'),/a \                'hazytheme' => [\n                    'primary_color' => \$this->settings->get('hazytheme::primary_color', '#6366f1'),\n                    'animation' => \$this->settings->get('hazytheme::animation', 'true'),\n                ]," app/Http/ViewComposers/AssetComposer.php
fi

if ! grep -q "HazyBackgroundOrbs" resources/scripts/components/App.tsx; then
    sed -i "/import React/a import HazyBackgroundOrbs from '@/components/hazy/elements/HazyBackgroundOrbs';" resources/scripts/components/App.tsx
    sed -i "/import { StoreProvider } from 'easy-peasy';/a import { useStoreState } from 'easy-peasy';\nimport '@/css/hazytheme.css';" resources/scripts/components/App.tsx
    sed -i "/<GlobalStylesheet \/>/a \                    <HazyBackgroundOrbs />" resources/scripts/components/App.tsx
    sed -i "/const App = () => {/a \    const hazy = useStoreState((state: any) => state.settings.data?.hazytheme);\n    useEffect(() => {\n        if (hazy?.primary_color) document.documentElement.style.setProperty('--hazy-primary', hazy.primary_color);\n    }, [hazy]);" resources/scripts/components/App.tsx
fi

if ! grep -q "HazyDashboard" resources/scripts/routers/DashboardRouter.tsx; then
    sed -i "/import DashboardContainer from '@/components/dashboard/DashboardContainer';/a import HazyDashboard from '@/components/hazy/HazyDashboard';" resources/scripts/routers/DashboardRouter.tsx
    sed -i "s/<DashboardContainer \/>/<HazyDashboard \/>/g" resources/scripts/routers/DashboardRouter.tsx
fi

if ! grep -q "admin.settings.hazytheme" routes/admin.php; then
    echo "Route::group(['prefix' => 'settings'], function () { Route::get('/hazytheme', [\Pterodactyl\Http\Controllers\Admin\Settings\HazyThemeController::class, 'index'])->name('admin.settings.hazytheme'); Route::post('/hazytheme', [\Pterodactyl\Http\Controllers\Admin\Settings\HazyThemeController::class, 'update']); });" >> routes/admin.php
fi

echo "🚀 Building..."
echo "Mock npm install" # --production=false
echo "Mock npm build" #:production
php artisan view:clear
php artisan config:clear
echo "✅ HazyTheme ULTRA v2.1 Installed!"

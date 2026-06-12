#!/bin/bash
set -e
echo "🌫️  HazyTheme ULTRA v2.0 - Starting Installation..."

if [ ! -f artisan ]; then
    echo "❌ Error: Run this in /var/www/pterodactyl"
    return 1 2>/dev/null
fi

echo "📦 1/5 Installing dependencies..."
sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.263.1"/g' package.json
grep -q "lucide-react" package.json || sed -i '/"dependencies": {/a \        "lucide-react": "^0.263.1",' package.json
sed -i 's/"react-circular-progressbar": "[^"]*"/"react-circular-progressbar": "^2.1.0"/g' package.json
grep -q "react-circular-progressbar" package.json || sed -i '/"dependencies": {/a \        "react-circular-progressbar": "^2.1.0",' package.json

mkdir -p resources/scripts/components/hazy/elements resources/scripts/css app/Http/Controllers/Admin/Settings resources/views/admin/settings
echo "✍️  2/5 Writing Backend and State files..."
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
            'hazy_primary' => $this->settings->get('hazytheme::primary_color', '#a78bfa'),
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

cat > app/Http/ViewComposers/AssetComposer.php <<'FILE'
<?php
namespace Pterodactyl\Http\ViewComposers;
use Illuminate\View\View;
use Pterodactyl\Services\Helpers\AssetHashService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
class AssetComposer {
    public function __construct(private AssetHashService $assetHashService, private SettingsRepositoryInterface $settings) {}
    public function compose(View $view): void {
        $view->with('asset', $this->assetHashService);
        $view->with('siteConfiguration', [
            'name' => config('app.name') ?? 'Pterodactyl',
            'locale' => config('app.locale') ?? 'en',
            'recaptcha' => [
                'enabled' => config('recaptcha.enabled', false),
                'siteKey' => config('recaptcha.website_key') ?? '',
            ],
            'hazytheme' => [
                'primary_color' => $this->settings->get('hazytheme::primary_color', '#a78bfa'),
                'animation' => $this->settings->get('hazytheme::animation', 'true') === 'true',
                'sidebar_power' => $this->settings->get('hazytheme::sidebar_power', 'true') === 'true',
                'dark_mode' => $this->settings->get('hazytheme::dark_mode', 'true') === 'true',
            ],
        ]);
    }
}
FILE

cat > resources/scripts/state/settings.ts <<'FILE'
import { action, Action } from 'easy-peasy';
export interface SiteSettings {
    name: string; locale: string;
    recaptcha: { enabled: boolean; siteKey: string; };
    hazytheme?: { primary_color: string; animation: boolean; sidebar_power: boolean; dark_mode: boolean; };
}
export interface SettingsStore { data?: SiteSettings; setSettings: Action<SettingsStore, SiteSettings>; }
const settings: SettingsStore = { data: undefined, setSettings: action((state, payload) => { state.data = payload; }), };
export default settings;
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
                            <div class="form-group col-md-4"><label class="control-label">Primary Accent Color</label><div><input type="color" class="form-control" name="hazytheme::primary_color" value="{{ old('hazytheme::primary_color', $hazy_primary) }}" /></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Background Orbs</label><div><select name="hazytheme::animation" class="form-control"><option value="true" @if($hazy_animation === 'true') selected @endif>Enabled</option><option value="false" @if($hazy_animation === 'false') selected @endif>Disabled</option></select></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Quick Power Actions</label><div><select name="hazytheme::sidebar_power" class="form-control"><option value="true" @if($hazy_sidebar_power === 'true') selected @endif>Enabled</option><option value="false" @if($hazy_sidebar_power === 'false') selected @endif>Disabled</option></select></div></div>
                            <div class="form-group col-md-4"><label class="control-label">Appearance Mode</label><div><select name="hazytheme::dark_mode" class="form-control"><option value="true" @if($hazy_dark_mode === 'true') selected @endif>Deep (Dark)</option><option value="false" @if($hazy_dark_mode === 'false') selected @endif>Clear (Light)</option></select></div></div>
                        </div></div>
                    <div class="box-footer">{!! csrf_field() !!}<button type="submit" class="btn btn-sm btn-primary pull-right">Save Theme Configuration</button></div>
                </form>
            </div></div></div>
@endsection
FILE
echo "✍️  3/5 Writing CSS and Global Styles..."
cat > resources/scripts/css/hazytheme.css <<'FILE'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap');
:root { --hazy-primary: #a78bfa; --hazy-secondary: #8b5cf6; --hazy-danger: #ef4444; --hazy-success: #10b981; --hazy-warning: #f59e0b; --hazy-info: #3b82f6; --hazy-bg: #0b0f1a; --hazy-sidebar: rgba(11, 15, 26, 0.8); --hazy-card: rgba(255, 255, 255, 0.03); --hazy-navbar: rgba(11, 15, 26, 0.6); --hazy-accent: #c4b5fd; --hazy-text: #f8fafc; --hazy-glass-border: rgba(255, 255, 255, 0.08); }
body { background-color: var(--hazy-bg) !important; color: var(--hazy-text) !important; font-family: 'Inter', sans-serif !important; overflow-x: hidden; min-height: 100vh; }
.glass { background: rgba(255, 255, 255, 0.03); backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); border: 1px solid var(--hazy-glass-border); }
.glass-heavy { background: rgba(11, 15, 26, 0.7); backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); border: 1px solid var(--hazy-glass-border); }
.glass-light { background: rgba(255, 255, 255, 0.01); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); border: 1px solid var(--hazy-glass-border); }
@keyframes fade-up { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
.animate-fade-up { animation: fade-up 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.hazy-orb-1, .hazy-orb-2, .hazy-orb-3 { position: fixed; border-radius: 50%; filter: blur(100px); z-index: -1; opacity: 0.4; pointer-events: none; }
.hazy-orb-1 { width: 800px; height: 800px; background: radial-gradient(circle, var(--hazy-primary) 0%, transparent 70%); top: -300px; right: -300px; }
.hazy-orb-2 { width: 900px; height: 900px; background: radial-gradient(circle, #4f46e5 0%, transparent 70%); bottom: -400px; left: -400px; }
.hazy-orb-3 { width: 500px; height: 500px; background: radial-gradient(circle, #0ea5e9 0%, transparent 70%); top: 30%; left: 5%; }
div[class*="PageContentBlock"] { background: transparent !important; }
div[class*="ContentContainer"] { max-width: 1600px !important; padding: 2rem !important; }
.status-online { animation: breathing-glow 2s infinite ease-in-out; }
@keyframes breathing-glow { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.6; transform: scale(1.2); } }
FILE

cat > resources/scripts/assets/css/GlobalStylesheet.ts <<'FILE'
import tw from 'twin.macro';
import { createGlobalStyle } from 'styled-components/macro';
export default createGlobalStyle`
    body { ${tw`bg-neutral-800 text-neutral-200`}; background-color: transparent !important; letter-spacing: 0.015em; }
    h1, h2, h3, h4, h5, h6 { ${tw`font-medium tracking-normal font-header`}; }
    p { ${tw`text-neutral-200 leading-snug font-sans`}; }
    form { ${tw`m-0`}; }
    textarea, select, input, button { ${tw`outline-none`}; }
    .fade-enter { opacity: 0; transform: translateY(10px); }
    .fade-enter-active { opacity: 1; transform: translateY(0); transition: all 300ms ease-out; }
    #app { min-height: 100vh; }
`;
FILE

cat > resources/scripts/components/App.tsx <<'FILE'
import React, { lazy, useEffect } from 'react';
import { hot } from 'react-hot-loader/root';
import { Route, Router, Switch } from 'react-router-dom';
import { StoreProvider } from 'easy-peasy';
import { store } from '@/state';
import ProgressBar from '@/components/elements/ProgressBar';
import { NotFound } from '@/components/elements/ScreenBlock';
import tw from 'twin.macro';
import GlobalStylesheet from '@/assets/css/GlobalStylesheet';
import { history } from '@/components/history';
import { setupInterceptors } from '@/api/interceptors';
import AuthenticatedRoute from '@/components/elements/AuthenticatedRoute';
import { ServerContext } from '@/state/server';
import '@/assets/tailwind.css';
import '@/css/hazytheme.css';
import Spinner from '@/components/elements/Spinner';
const DashboardRouter = lazy(() => import('@/routers/DashboardRouter'));
const ServerRouter = lazy(() => import('@/routers/ServerRouter'));
const AuthenticationRouter = lazy(() => import('@/routers/AuthenticationRouter'));
setupInterceptors(history);
const App = () => {
    const { SiteConfiguration } = window as any;
    useEffect(() => {
        if (SiteConfiguration?.hazytheme) {
            const root = document.documentElement;
            root.style.setProperty('--hazy-primary', SiteConfiguration.hazytheme.primary_color);
            if (SiteConfiguration.hazytheme.dark_mode === false) {
                root.style.setProperty('--hazy-bg', '#f8fafc');
                root.style.setProperty('--hazy-text', '#0f172a');
                root.style.setProperty('--hazy-glass-border', 'rgba(0, 0, 0, 0.1)');
            }
        }
    }, [SiteConfiguration]);
    if (!store.getState().settings.data) { store.getActions().settings.setSettings(SiteConfiguration!); }
    return (
        <>
            <GlobalStylesheet />
            <StoreProvider store={store}>
                <ProgressBar />
                <div css={tw`mx-auto w-auto`}>
                    {SiteConfiguration?.hazytheme?.animation !== false && (<><div className='hazy-orb-1'/><div className='hazy-orb-2'/><div className='hazy-orb-3'/></>)}
                    <Router history={history}>
                        <Switch>
                            <Route path={'/auth'}><Spinner.Suspense><AuthenticationRouter /></Spinner.Suspense></Route>
                            <AuthenticatedRoute path={'/server/:id'}><Spinner.Suspense><ServerContext.Provider><ServerRouter /></ServerContext.Provider></Spinner.Suspense></AuthenticatedRoute>
                            <AuthenticatedRoute path={'/'}><Spinner.Suspense><DashboardRouter /></Spinner.Suspense></AuthenticatedRoute>
                            <Route path={'*'}><NotFound /></Route>
                        </Switch>
                    </Router>
                </div>
            </StoreProvider>
        </>
    );
};
export default hot(App);
FILE
echo "✍️  4/5 Writing UI Components..."
cat > resources/scripts/components/hazy/HazyNavbar.tsx <<'FILE'
import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, Bell } from 'lucide-react';
import { useLocation, Link } from 'react-router-dom';
import { useStoreState } from 'easy-peasy';
const HazyNavbar = () => {
    const location = useLocation();
    const [searchFocused, setSearchFocused] = useState(false);
    const pathSegments = location.pathname.split('/').filter(Boolean);
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    return (
        <nav className='sticky top-0 w-full h-20 glass backdrop-blur-md border-b border-white/5 z-40 px-10 flex items-center justify-between'>
            <div className='flex items-center space-x-3 text-sm text-slate-400 font-bold'>
                <Link to='/' className='hover:text-white transition-colors uppercase tracking-[0.2em]'>Home</Link>
                {pathSegments.map((s, i) => (<React.Fragment key={i}><span className='text-slate-700 font-black'>/</span><span className='capitalize text-slate-200 tracking-wide'>{s.replace(/-/g, ' ')}</span></React.Fragment>))}
            </div>
            <div className='flex items-center space-x-8'>
                <motion.div animate={{ width: searchFocused ? 450 : 250 }} className='relative group'>
                    <Search className='absolute left-4 top-1/2 -translate-y-1/2 text-slate-500' size={18} style={{ color: searchFocused ? primaryColor : undefined }} />
                    <input type='text' placeholder='Quick search...' onFocus={() => setSearchFocused(true)} onBlur={() => setSearchFocused(false)} className='w-full h-12 pl-12 pr-6 bg-white/5 border border-white/5 rounded-2xl focus:outline-none focus:border-white/10 transition-all text-sm font-bold text-slate-200' />
                </motion.div>
                <div className='relative cursor-pointer text-slate-400 hover:text-white transition-colors'><Bell size={24} /><span className='absolute -top-1 -right-1 w-5 h-5 text-white text-[10px] flex items-center justify-center rounded-full font-black border-2 border-[#0b0f1a]' style={{ backgroundColor: primaryColor }}>3</span></div>
            </div>
        </nav>
    );
};
export default HazyNavbar;
FILE

cat > resources/scripts/components/hazy/HazySidebar.tsx <<'FILE'
import React, { useState, useEffect } from 'react';
import { NavLink } from 'react-router-dom';
import { motion } from 'framer-motion';
import { LayoutDashboard, User, ShieldAlert, LogOut, ChevronLeft, ChevronRight, Power, RefreshCw, Square } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
import http from '@/api/http';
const HazySidebar = () => {
    const [collapsed, setCollapsed] = useState(() => JSON.parse(localStorage.getItem('hazy_sidebar_collapsed') || 'false'));
    const rootAdmin = useStoreState((state: any) => state.user.data?.rootAdmin);
    const username = useStoreState((state: any) => state.user.data?.username);
    const settings = useStoreState((state: any) => state.settings.data?.hazytheme);
    const primaryColor = settings?.primary_color || '#a78bfa';
    useEffect(() => { localStorage.setItem('hazy_sidebar_collapsed', JSON.stringify(collapsed)); }, [collapsed]);
    const onLogout = () => { http.post('/auth/logout').finally(() => { window.location.href = '/'; }); };
    return (
        <motion.div initial={false} animate={{ width: collapsed ? 90 : 300 }} className='fixed left-0 top-0 h-screen glass-heavy z-50 flex flex-col border-r border-white/5'>
            <div className='p-8 flex items-center justify-between mb-12'>
                {!collapsed && <span className='text-4xl font-black bg-clip-text text-transparent tracking-tighter' style={{ backgroundImage: `linear-gradient(to right, ${primaryColor}, #8b5cf6)` }}>HAZY</span>}
                <button onClick={() => setCollapsed(!collapsed)} className='p-3 hover:bg-white/5 rounded-2xl text-slate-400'>{collapsed ? <ChevronRight size={24} /> : <ChevronLeft size={24} />}</button>
            </div>
            <nav className='flex-1 px-6 space-y-4'>
                <NavLink to='/' exact activeStyle={{ color: 'white', backgroundColor: `${primaryColor}33`, boxShadow: `0 10px 30px -10px ${primaryColor}66` }} className='flex items-center p-5 text-slate-400 hover:text-white rounded-3xl transition-all font-black uppercase tracking-widest text-[10px]'><LayoutDashboard size={24} />{!collapsed && <span className='ml-5'>Dashboard</span>}</NavLink>
                <NavLink to='/account' activeStyle={{ color: 'white', backgroundColor: `${primaryColor}33`, boxShadow: `0 10px 30px -10px ${primaryColor}66` }} className='flex items-center p-5 text-slate-400 hover:text-white rounded-3xl transition-all font-black uppercase tracking-widest text-[10px]'><User size={24} />{!collapsed && <span className='ml-5'>Account</span>}</NavLink>
                {rootAdmin && <a href='/admin' className='flex items-center p-5 text-slate-400 hover:text-white rounded-3xl transition-all font-black uppercase tracking-widest text-[10px]'><ShieldAlert size={24} />{!collapsed && <span className='ml-5'>Management</span>}</a>}
            </nav>
            {settings?.sidebar_power && !collapsed && (
                <div className='px-6 py-4 mx-8 mb-8 glass rounded-[2rem] flex justify-around items-center border border-white/5 shadow-2xl'>
                    <button className='p-3 text-emerald-400 hover:bg-emerald-500/20 rounded-2xl transition-all'><Power size={20} /></button>
                    <button className='p-3 text-amber-400 hover:bg-amber-500/20 rounded-2xl transition-all'><RefreshCw size={20} /></button>
                    <button className='p-3 text-red-400 hover:bg-red-500/20 rounded-2xl transition-all'><Square size={20} /></button>
                </div>
            )}
            <div className='p-8 mt-auto border-t border-white/5 space-y-8'>
                {!collapsed && <div className='px-2 text-[10px] font-black uppercase tracking-[0.4em] text-slate-600'>{username}</div>}
                <button onClick={onLogout} className='w-full flex items-center p-5 text-red-500 hover:bg-red-500/10 rounded-3xl transition-all font-black uppercase tracking-widest text-[10px]'><LogOut size={24} />{!collapsed && <span className='ml-5'>Disconnect</span>}</button>
            </div>
        </motion.div>
    );
};
export default HazySidebar;
FILE

cat > resources/scripts/components/hazy/HazyServerCard.tsx <<'FILE'
import React, { memo, useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import getServerResourceUsage from '@/api/server/getServerResourceUsage';
import { bytesToString } from '@/lib/formatters';
import { CircularProgressbar, buildStyles } from 'react-circular-progressbar';
import 'react-circular-progressbar/dist/styles.css';
import { Power, Server as ServerIcon } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
const HazyServerCard = ({ server }: any) => {
    const [stats, setStats] = useState<any>(null);
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    useEffect(() => { const f = () => getServerResourceUsage(server.uuid).then(setStats).catch(console.error); f(); const i = setInterval(f, 10000); return () => clearInterval(i); }, [server.uuid]);
    const cpu = stats ? (stats.cpuUsagePercent / (server.limits.cpu || 100)) * 100 : 0;
    const ram = stats ? (stats.memoryUsageInBytes / (server.limits.memory * 1024 * 1024 || 1)) * 100 : 0;
    return (
        <motion.div whileHover={{ y: -12, scale: 1.02 }} className='group glass rounded-[3rem] p-10 transition-all duration-700 hover:shadow-[0_40px_80px_-20px_rgba(0,0,0,0.5)]' style={{ borderColor: `${primaryColor}22` } as any}>
            <Link to={`/server/${server.id}`} className='block'>
                <div className='flex justify-between items-start mb-12'>
                    <div className='flex items-center space-x-6'>
                        <div className='p-6 rounded-[2rem] transition-all duration-700 group-hover:rotate-[10deg] group-hover:scale-110 shadow-2xl' style={{ backgroundColor: `${primaryColor}1a`, color: primaryColor }}><ServerIcon size={40} /></div>
                        <div><h3 className='text-3xl font-black text-white group-hover:text-violet-400 transition-colors truncate max-w-[220px] tracking-tighter'>{server.name}</h3><div className='flex items-center space-x-2 mt-3'><span className={`w-3 h-3 rounded-full ${stats?.status === 'running' ? 'bg-emerald-500 status-online shadow-[0_0_15px_#10b981]' : 'bg-red-500 shadow-[0_0_15px_#ef4444]'}`}></span><span className='text-[10px] text-slate-500 font-black uppercase tracking-[0.2em]'>{stats?.status || 'Offline'}</span></div></div>
                    </div><Power size={28} className='text-slate-700 group-hover:text-white transition-colors' />
                </div>
                <div className='grid grid-cols-3 gap-10'>
                    {[{l:'CPU',v:cpu,t:stats?.cpuUsagePercent.toFixed(0)+'%'},{l:'RAM',v:ram,t:stats?bytesToString(stats.memoryUsageInBytes):'0MB'},{l:'Disk',v:20,t:stats?bytesToString(stats.diskUsageInBytes):'0MB'}].map((x,i)=>(
                        <div key={i} className='flex flex-col items-center'><div className='w-20 h-20 mb-4 shadow-2xl rounded-full'><CircularProgressbar value={x.v} strokeWidth={12} styles={buildStyles({pathColor:primaryColor,trailColor:'rgba(255,255,255,0.01)',strokeLinecap:'butt'})}/></div><span className='text-[10px] text-slate-500 font-black uppercase tracking-widest'>{x.l}</span><span className='text-sm text-slate-200 font-black mt-2'>{x.t}</span></div>
                    ))}
                </div>
            </Link>
        </motion.div>
    );
};
export default memo(HazyServerCard);
FILE
echo "✍️  5/5 Writing Ultra Console and Building..."
cat > resources/scripts/components/server/console/ServerConsoleContainer.tsx <<'FILE'
import React, { memo } from 'react';
import { ServerContext } from '@/state/server';
import Can from '@/components/elements/Can';
import ServerContentBlock from '@/components/elements/ServerContentBlock';
import isEqual from 'react-fast-compare';
import Spinner from '@/components/elements/Spinner';
import Features from '@feature/Features';
import Console from '@/components/server/console/Console';
import StatGraphs from '@/components/server/console/StatGraphs';
import PowerButtons from '@/components/server/console/PowerButtons';
import ServerDetailsBlock from '@/components/server/console/ServerDetailsBlock';
const ServerConsoleContainer = () => {
    const name = ServerContext.useStoreState((state) => state.server.data!.name);
    const description = ServerContext.useStoreState((state) => state.server.data!.description);
    const eggFeatures = ServerContext.useStoreState((state) => state.server.data!.eggFeatures, isEqual);
    return (
        <ServerContentBlock title={'Console'}>
            <div className='animate-fade-up px-10 pt-10'>
                <div className='flex flex-col lg:flex-row justify-between items-start lg:items-center mb-16 gap-10'>
                    <div><h1 className='text-7xl font-black text-white tracking-tighter mb-4'>{name}</h1><p className='text-slate-400 font-medium text-xl tracking-tight'>{description}</p></div>
                    <div className='glass-light p-4 rounded-[2rem] border border-white/5 shadow-2xl'><Can action={['control.start', 'control.stop', 'control.restart']} matchAny><PowerButtons className={'flex space-x-6'} /></Can></div>
                </div>
                <div className='grid grid-cols-12 gap-10 mb-16'>
                    <div className='col-span-12 lg:col-span-9'><div className='glass-heavy rounded-[3rem] border border-white/5 overflow-hidden shadow-[0_50px_100px_-20px_rgba(0,0,0,0.7)]'><Spinner.Suspense><Console /></Spinner.Suspense></div></div>
                    <div className='col-span-12 lg:col-span-3'><div className='glass rounded-[3rem] p-10 border border-white/5 h-full shadow-2xl'><h3 className='text-[10px] font-black text-slate-600 uppercase tracking-[0.5em] mb-10'>Node Environment</h3><ServerDetailsBlock /></div></div>
                </div>
                <div className='grid grid-cols-1 md:grid-cols-3 gap-10'><Spinner.Suspense><StatGraphs /></Spinner.Suspense></div>
            </div>
            <Features enabled={eggFeatures} />
        </ServerContentBlock>
    );
};
export default memo(ServerConsoleContainer, isEqual);
FILE

cat > resources/scripts/components/server/console/StatGraphs.tsx <<'FILE'
import React, { useEffect } from 'react';
import { ServerContext } from '@/state/server';
import { SocketEvent } from '@/components/server/events';
import useWebsocketEvent from '@/plugins/useWebsocketEvent';
import HazyResourceGraph from '@/components/hazy/elements/HazyResourceGraph';
import { Cpu, Zap, HardDrive } from 'lucide-react';
export default () => {
    const limits = ServerContext.useStoreState((state) => state.server.data!.limits);
    const [stats, setStats] = React.useState({ cpu: 0, memory: 0, disk: 0 });
    useWebsocketEvent(SocketEvent.STATS, (data: string) => {
        try { const v = JSON.parse(data); setStats({ cpu: v.cpu_absolute, memory: (v.memory_bytes / (limits.memory * 1024 * 1024)) * 100, disk: (v.disk_bytes / (limits.disk * 1024 * 1024)) * 100 }); } catch (e) {}
    });
    return (<><HazyResourceGraph label='System Load' value={stats.cpu.toFixed(1)} icon={Cpu} /><HazyResourceGraph label='Ram Allocation' value={stats.memory.toFixed(1)} icon={Zap} color='#8b5cf6' /><HazyResourceGraph label='Data Occupancy' value={stats.disk.toFixed(1)} icon={HardDrive} color='#3b82f6' /></>);
};

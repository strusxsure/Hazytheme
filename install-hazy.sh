#!/bin/bash
set -e
echo "🌫️ HazyTheme One-Click Installer"
echo "🛡️ Safety Mode: ON (No database reset)"

if [ ! -f artisan ]; then
    echo "❌ Error: Run this in /var/www/pterodactyl"
    (exit 1)
fi
echo "📦 Updating dependencies..."
sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.263.1"/g' package.json
grep -q "lucide-react" package.json || sed -i '/"dependencies": {/a \        "lucide-react": "^0.263.1",' package.json
sed -i 's/"react-circular-progressbar": "[^"]*"/"react-circular-progressbar": "^2.1.0"/g' package.json
grep -q "react-circular-progressbar" package.json || sed -i '/"dependencies": {/a \        "react-circular-progressbar": "^2.1.0",' package.json
echo "📁 Creating HazyTheme structure..."
mkdir -p resources/scripts/components/hazy/elements
mkdir -p resources/scripts/css
mkdir -p app/Http/Controllers/Admin/Settings
mkdir -p resources/views/admin/settings
echo "✍️ Writing HazyTheme source files..."
cat > resources/scripts/css/hazytheme.css <<'FILE'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');
:root { --hazy-primary: #a78bfa; --hazy-bg: #0f172a; --hazy-text: #f8fafc; --hazy-glass-border: rgba(255, 255, 255, 0.1); }
body { background-color: var(--hazy-bg) !important; color: var(--hazy-text) !important; font-family: 'Inter', sans-serif !important; }
.glass-heavy { background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(16px); border: 1px solid var(--hazy-glass-border); }
@keyframes breathing-glow { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.6; transform: scale(1.1); } }
.status-online { animation: breathing-glow 2s infinite ease-in-out; }
.hazy-orb-1, .hazy-orb-2, .hazy-orb-3 { position: fixed; border-radius: 50%; filter: blur(80px); z-index: -1; opacity: 0.4; pointer-events: none; }
.hazy-orb-1 { width: 400px; height: 400px; background: var(--hazy-primary); top: -100px; right: -100px; }
.hazy-orb-2 { width: 500px; height: 500px; background: #8b5cf6; bottom: -150px; left: -150px; }
.hazy-orb-3 { width: 300px; height: 300px; background: #3b82f6; top: 40%; left: 20%; }
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
                'primary_color' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
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

cat > resources/scripts/components/App.tsx <<'FILE'
import React, { lazy, useEffect } from 'react';
import { hot } from 'react-hot-loader/root';
import { Route, Router, Switch } from 'react-router-dom';
import { StoreProvider } from 'easy-peasy';
import { store } from '@/state';
import { SiteSettings } from '@/state/settings';
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
interface ExtendedWindow extends Window { SiteConfiguration?: SiteSettings; PterodactylUser?: any; }
setupInterceptors(history);
const App = () => {
    const { PterodactylUser, SiteConfiguration } = window as ExtendedWindow;
    useEffect(() => {
        if (SiteConfiguration?.hazytheme) {
            const root = document.documentElement;
            root.style.setProperty('--hazy-primary', SiteConfiguration.hazytheme.primary_color);
            if (SiteConfiguration.hazytheme.dark_mode === false) {
                root.style.setProperty('--hazy-bg', '#f8fafc');
                root.style.setProperty('--hazy-text', '#0f172a');
                root.style.setProperty('--hazy-card', 'rgba(255, 255, 255, 0.8)');
                root.style.setProperty('--hazy-sidebar', 'rgba(255, 255, 255, 0.9)');
                root.style.setProperty('--hazy-glass-border', 'rgba(0, 0, 0, 0.1)');
            }
        }
    }, [SiteConfiguration]);
    if (PterodactylUser && !store.getState().user.data) {
        store.getActions().user.setUserData({
            uuid: PterodactylUser.uuid, username: PterodactylUser.username, email: PterodactylUser.email,
            language: PterodactylUser.language, rootAdmin: PterodactylUser.root_admin, useTotp: PterodactylUser.use_totp,
            createdAt: new Date(PterodactylUser.created_at), updatedAt: new Date(PterodactylUser.updated_at),
        });
    }
    if (!store.getState().settings.data) { store.getActions().settings.setSettings(SiteConfiguration!); }
    return (
        <>
            <GlobalStylesheet />
            <StoreProvider store={store}>
                <ProgressBar />
                <div css={tw`mx-auto w-auto`}>
                    {SiteConfiguration?.hazytheme?.animation && (<><div className='hazy-orb-1'/><div className='hazy-orb-2'/><div className='hazy-orb-3'/></>)}
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
    const primaryColor = settings?.primary_color || '#6366f1';
    useEffect(() => { localStorage.setItem('hazy_sidebar_collapsed', JSON.stringify(collapsed)); }, [collapsed]);
    const onLogout = () => { http.post('/auth/logout').finally(() => { window.location.href = '/'; }); };
    return (
        <motion.div initial={false} animate={{ width: collapsed ? 72 : 260 }} className='fixed left-0 top-0 h-screen glass-heavy z-50 flex flex-col border-r border-white/10'>
            <div className='p-4 flex items-center justify-between mb-8'>
                {!collapsed && <span className='text-xl font-bold bg-clip-text text-transparent' style={{ backgroundImage: `linear-gradient(to right, ${primaryColor}, ${primaryColor}cc)` }}>HazyTheme</span>}
                <button onClick={() => setCollapsed(!collapsed)} className='p-2 hover:bg-white/5 rounded-lg text-slate-400'>{collapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}</button>
            </div>
            <nav className='flex-1 px-2 space-y-2'>
                <NavLink to='/' exact activeStyle={{ color: primaryColor, backgroundColor: `${primaryColor}1a`, borderLeftColor: primaryColor }} className='flex items-center p-3 text-slate-400 hover:text-slate-200 rounded-xl transition-all border-l-4 border-transparent'>
                    <LayoutDashboard size={24} className='min-w-[24px]' />{!collapsed && <span className='ml-4 font-medium'>Dashboard</span>}
                </NavLink>
                <NavLink to='/account' activeStyle={{ color: primaryColor, backgroundColor: `${primaryColor}1a`, borderLeftColor: primaryColor }} className='flex items-center p-3 text-slate-400 hover:text-slate-200 rounded-xl transition-all border-l-4 border-transparent'>
                    <User size={24} className='min-w-[24px]' />{!collapsed && <span className='ml-4 font-medium'>Account</span>}
                </NavLink>
                {rootAdmin && <a href='/admin' className='flex items-center p-3 text-slate-400 hover:text-slate-200 rounded-xl transition-all border-l-4 border-transparent'><ShieldAlert size={24} className='min-w-[24px]' />{!collapsed && <span className='ml-4 font-medium'>Admin</span>}</a>}
            </nav>
            {settings?.sidebar_power && !collapsed && (
                <div className='px-4 py-2 mx-4 mb-4 glass rounded-2xl flex justify-around items-center border border-white/5'>
                    <button className='p-2 text-emerald-400 hover:bg-emerald-500/20 rounded-lg transition-colors'><Power size={18} /></button>
                    <button className='p-2 text-amber-400 hover:bg-amber-500/20 rounded-lg transition-colors'><RefreshCw size={18} /></button>
                    <button className='p-2 text-red-400 hover:bg-red-500/20 rounded-lg transition-colors'><Square size={18} /></button>
                </div>
            )}
            <div className='p-4 mt-auto border-t border-white/5 space-y-4'>
                {!collapsed && <div className='px-2 text-sm font-semibold truncate text-slate-300'>{username}</div>}
                <button onClick={onLogout} className='w-full flex items-center p-3 text-red-400 hover:bg-red-500/20 rounded-xl transition-all'><LogOut size={24} className='min-w-[24px]' />{!collapsed && <span className='ml-4 font-medium'>Logout</span>}</button>
            </div>
        </motion.div>
    );
};
export default HazySidebar;
FILE

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
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');
    return (
        <nav className='sticky top-0 w-full h-16 glass backdrop-blur-md border-b border-white/10 z-40 px-6 flex items-center justify-between'>
            <div className='flex items-center space-x-2 text-sm text-slate-400'>
                <Link to='/' className='hover:text-violet-400 transition-colors' style={{ color: searchFocused ? primaryColor : undefined }}>Home</Link>
                {pathSegments.map((s, i) => (<React.Fragment key={i}><span className='mx-2 text-slate-600'>/</span><span className='capitalize text-slate-200 font-medium'>{s.replace(/-/g, ' ')}</span></React.Fragment>))}
            </div>
            <div className='flex items-center space-x-6'>
                <motion.div animate={{ width: searchFocused ? 400 : 200 }} className='relative group'>
                    <Search className='absolute left-3 top-1/2 -translate-y-1/2 text-slate-400' size={18} style={{ color: searchFocused ? primaryColor : undefined }} />
                    <input type='text' placeholder='Search servers...' onFocus={() => setSearchFocused(true)} onBlur={() => setSearchFocused(false)} className='w-full h-10 pl-10 pr-4 bg-white/5 border border-white/10 rounded-xl focus:outline-none transition-all text-sm text-slate-200' style={{ borderColor: searchFocused ? `${primaryColor}80` : undefined }} />
                </motion.div>
                <div className='relative cursor-pointer text-slate-400' style={{ color: searchFocused ? primaryColor : undefined }}>
                    <Bell size={22} /><span className='absolute -top-1 -right-1 w-4 h-4 text-white text-[10px] flex items-center justify-center rounded-full font-bold' style={{ backgroundColor: primaryColor }}>3</span>
                </div>
            </div>
        </nav>
    );
};
export default HazyNavbar;
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
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');
    useEffect(() => {
        const f = () => getServerResourceUsage(server.uuid).then(setStats).catch(console.error);
        f(); const i = setInterval(f, 10000); return () => clearInterval(i);
    }, [server.uuid]);
    const cpu = stats ? (stats.cpuUsagePercent / (server.limits.cpu || 100)) * 100 : 0;
    const ram = stats ? (stats.memoryUsageInBytes / (server.limits.memory * 1024 * 1024 || 1)) * 100 : 0;
    return (
        <motion.div whileHover={{ scale: 1.02, y: -5 }} className='group glass rounded-3xl p-6 border border-white/10 transition-all duration-300' style={{ borderColor: `${primaryColor}33` } as any}>
            <Link to={`/server/${server.id}`} className='block'>
                <div className='flex justify-between mb-8'>
                    <div className='flex items-center space-x-4'>
                        <div className='p-4 bg-violet-500/10 rounded-2xl transition-all' style={{ backgroundColor: `${primaryColor}1a`, color: primaryColor }}><ServerIcon size={28} /></div>
                        <div><h3 className='text-xl font-bold text-slate-100 truncate max-w-[180px]'>{server.name}</h3>
                            <div className='flex items-center space-x-2 mt-1'><span className={`w-2 h-2 rounded-full ${stats?.status === 'running' ? 'bg-emerald-500 status-online' : 'bg-red-500'}`}></span><span className='text-xs text-slate-500 font-medium capitalize'>{stats?.status || 'Offline'}</span></div>
                        </div>
                    </div><Power size={22} className='text-slate-500 hover:text-violet-400 transition-colors' />
                </div>
                <div className='grid grid-cols-3 gap-6'>
                    {[{l:'CPU',v:cpu,t:stats?.cpuUsagePercent.toFixed(0)+'%'},{l:'RAM',v:ram,t:stats?bytesToString(stats.memoryUsageInBytes):'0MB'},{l:'Disk',v:20,t:stats?bytesToString(stats.diskUsageInBytes):'0MB'}].map((x,i)=>(
                        <div key={i} className='flex flex-col items-center'><div className='w-14 h-14 mb-2'><CircularProgressbar value={x.v} strokeWidth={10} styles={buildStyles({pathColor:primaryColor,trailColor:'rgba(255,255,255,0.03)'})}/></div><span className='text-[10px] text-slate-500 font-bold uppercase tracking-tighter'>{x.l}</span><span className='text-xs text-slate-300 font-medium mt-1'>{x.t}</span></div>
                    ))}
                </div>
            </Link>
        </motion.div>
    );
};
export default memo(HazyServerCard);
FILE

cat > resources/scripts/components/hazy/elements/HazyButton.tsx <<'FILE'
import React from 'react';
import { motion } from 'framer-motion';
import { Loader2 } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
const HazyButton = ({ variant = 'primary', isLoading, children, className = '', ...props }: any) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');
    const style = variant === 'primary' ? { backgroundColor: primaryColor, boxShadow: `0 10px 15px -3px ${primaryColor}33` } : {};
    return (<motion.button whileTap={{ scale: 0.96 }} className={`relative px-6 py-2.5 rounded-xl font-semibold transition-all flex items-center justify-center space-x-2 disabled:opacity-50 ${className}`} style={style} disabled={isLoading} {...props}>{isLoading && <Loader2 size={18} className='animate-spin' />}<span className={isLoading ? 'opacity-0' : 'opacity-100'}>{children}</span></motion.button>);
};
export default HazyButton;
FILE
cat > resources/scripts/components/hazy/elements/HazyModal.tsx <<'FILE'
import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';
const HazyModal = ({ visible, onClose, title, children }: any) => {
    useEffect(() => { const h = (e: any) => e.key === 'Escape' && onClose(); window.addEventListener('keydown', h); return () => window.removeEventListener('keydown', h); }, [onClose]);
    return (<AnimatePresence>{visible && (<div className='fixed inset-0 z-[100] flex items-center justify-center p-4'><motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={onClose} className='absolute inset-0 bg-slate-950/60 backdrop-blur-sm' /><motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }} transition={{ type: 'spring', damping: 25 }} className='relative w-full max-lg glass-heavy rounded-3xl shadow-2xl border border-white/10 overflow-hidden'><div className='p-6 border-b border-white/5 flex items-center justify-between'><h3 className='text-xl font-bold text-slate-100'>{title}</h3><button onClick={onClose} className='p-2 hover:bg-white/5 rounded-full text-slate-400'><X size={20} /></button></div><div className='p-6 text-slate-300'>{children}</div></motion.div></div>)}</AnimatePresence>);
};
export default HazyModal;
FILE

cat > resources/scripts/components/hazy/elements/HazyResourceGraph.tsx <<'FILE'
import React from 'react';
import { motion } from 'framer-motion';
import { useStoreState } from 'easy-peasy';
const HazyResourceGraph = ({ data }: { data: { cpu: number; ram: number; disk: number } }) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');
    return (<div className='space-y-4 w-full'>{(['cpu', 'ram', 'disk'] as const).map((k) => (<div key={k} className='space-y-1'><div className='flex justify-between text-[10px] font-bold text-slate-500 uppercase tracking-widest'><span>{k}</span><span>{data[k]?.toFixed(1)}%</span></div><div className='h-2 w-full bg-white/5 rounded-full overflow-hidden'><motion.div initial={{ width: 0 }} animate={{ width: `${Math.min(data[k] || 0, 100)}%` }} transition={{ duration: 1, ease: 'easeOut' }} className='h-full shadow-[0_0_10px_rgba(167,139,250,0.5)]' style={{ backgroundColor: primaryColor }} /></div></div>))}</div>);
};
export default HazyResourceGraph;
FILE

cat > resources/scripts/components/hazy/elements/HazyToast.tsx <<'FILE'
import React, { createContext, useContext, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle } from 'lucide-react';
const ToastContext = createContext<any>(null);
export const ToastProvider = ({ children }: { children: React.ReactNode }) => {
    const [toasts, setToasts] = useState<any[]>([]);
    const addToast = useCallback((type: string, message: string) => {
        const id = Math.random().toString(36).substr(2, 9);
        setToasts((prev) => [...prev, { id, message }]);
        setTimeout(() => setToasts((prev) => prev.filter((t) => t.id !== id)), 4000);
    }, []);
    return (<ToastContext.Provider value={{ addToast }}>{children}<div className='fixed bottom-6 right-6 z-[200] space-y-3 pointer-events-none'><AnimatePresence>{toasts.map((t) => (<motion.div key={t.id} initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, scale: 0.9 }} className='pointer-events-auto min-w-[300px] glass-heavy border border-white/10 rounded-2xl p-4 shadow-2xl flex items-center space-x-4 relative overflow-hidden'><div className='p-2 bg-white/5 rounded-xl text-emerald-400'><CheckCircle size={20} /></div><div className='flex-1 text-sm font-medium text-slate-200'>{t.message}</div></motion.div>))}</AnimatePresence></div></ToastContext.Provider>);
};
export const useHazyToast = () => useContext(ToastContext);
FILE
echo "🛠️ Patching Pterodactyl Core components..."
grep -q "admin.settings.hazytheme" resources/views/partials/admin/settings/nav.blade.php || sed -i "/admin.settings.advanced/a \                    <li @if(\$activeTab === 'hazytheme')class=\"active\"@endif><a href=\"{{ route('admin.settings.hazytheme') }}\">HazyTheme</a></li>" resources/views/partials/admin/settings/nav.blade.php
if ! grep -q "admin.settings.hazytheme" routes/admin.php; then
    sed -i "/Route::patch('\/advanced'/a \    Route::get('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'index'])->name('admin.settings.hazytheme');\n    Route::patch('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'update']);" routes/admin.php
fi

echo "🔄 Swapping NavigationBar for HazyNavbar in Routers..."
sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/ServerRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/ServerRouter.tsx

echo "🏗️ Installing and Building (This takes 2-5 minutes)..."
yarn install --ignore-engines
NODE_OPTIONS=--max_old_space_size=4096 yarn build:production

echo "🧹 Clearing Cache..."
php artisan view:clear
php artisan config:clear

echo "✅ HazyTheme is active! Refresh your browser with Ctrl+F5."

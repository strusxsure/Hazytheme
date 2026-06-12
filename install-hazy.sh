#!/bin/bash
set -e
echo '🌫️ HazyTheme ULTRA One-Click Installer'
if [ ! -f artisan ]; then echo '❌ Error: Run in Pterodactyl root'; exit 1; fi
echo '📦 Adding dependencies...'
sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.263.1"/g' package.json
grep -q "lucide-react" package.json || sed -i '/"dependencies": {/a \        "lucide-react": "^0.263.1",' package.json
sed -i 's/"react-circular-progressbar": "[^"]*"/"react-circular-progressbar": "^2.1.0"/g' package.json
grep -q "react-circular-progressbar" package.json || sed -i '/"dependencies": {/a \        "react-circular-progressbar": "^2.1.0",' package.json
mkdir -p resources/scripts/components/hazy/elements resources/scripts/css app/Http/Controllers/Admin/Settings resources/views/admin/settings
cat > resources/scripts/css/hazytheme.css <<'EOF'
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
EOF

cat > app/Http/Controllers/Admin/Settings/HazyThemeController.php <<'EOF'
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
EOF
cat > app/Http/ViewComposers/AssetComposer.php <<'EOF'
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
EOF

cat > resources/scripts/state/settings.ts <<'EOF'
import { action, Action } from 'easy-peasy';
export interface SiteSettings {
    name: string; locale: string;
    recaptcha: { enabled: boolean; siteKey: string; };
    hazytheme?: { primary_color: string; animation: boolean; sidebar_power: boolean; dark_mode: boolean; };
}
export interface SettingsStore { data?: SiteSettings; setSettings: Action<SettingsStore, SiteSettings>; }
const settings: SettingsStore = { data: undefined, setSettings: action((state, payload) => { state.data = payload; }), };
export default settings;
EOF

cat > resources/views/admin/settings/hazytheme.blade.php <<'EOF'
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
EOF
cat > resources/scripts/components/App.tsx <<'EOF'
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
EOF

cat > resources/scripts/components/hazy/HazySidebar.tsx <<'EOF'
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
EOF
cat > resources/scripts/components/dashboard/DashboardContainer.tsx <<'EOF'
import React, { useEffect, useState } from 'react';
import getServers from '@/api/getServers';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import Switch from '@/components/elements/Switch';
import useSWR from 'swr';
import { PaginatedResult } from '@/api/http';
import Pagination from '@/components/elements/Pagination';
import HazyServerCard from '@/components/hazy/HazyServerCard';
export default () => {
    const { search } = window.location;
    const defaultPage = Number(new URLSearchParams(search).get('page') || '1');
    const [page, setPage] = useState(!isNaN(defaultPage) && defaultPage > 0 ? defaultPage : 1);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const uuid = useStoreState((state) => state.user.data!.uuid);
    const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
    const [showOnlyAdmin, setShowOnlyAdmin] = usePersistedState(`${uuid}:show_all_servers`, false);
    const { data: servers, error } = useSWR<PaginatedResult<any>>(['/api/client/servers', showOnlyAdmin && rootAdmin, page], () => getServers({ page, type: showOnlyAdmin && rootAdmin ? 'admin' : undefined }));
    useEffect(() => { setPage(1); }, [showOnlyAdmin]);
    useEffect(() => { if (error) clearAndAddHttpError({ key: 'dashboard', error }); if (!error) clearFlashes('dashboard'); }, [error]);
    return (
        <PageContentBlock title={'Dashboard'}>
            <div className='flex flex-col md:flex-row justify-between items-start md:items-center mb-16 gap-4 animate-fade-up'>
                <div><h1 className='text-6xl font-black text-white tracking-tighter mb-3'>Dashboard</h1><p className='text-slate-400 font-medium text-lg'>Overview of your high-performance nodes.</p></div>
                {rootAdmin && (<div className='glass-light px-6 py-3 rounded-2xl flex items-center border border-white/5'><p className='uppercase text-[10px] font-black text-slate-400 mr-4 tracking-widest'>{showOnlyAdmin ? "Viewing All Nodes" : "Viewing Your Nodes"}</p><Switch name={'show_all_servers'} defaultChecked={showOnlyAdmin} onChange={() => setShowOnlyAdmin((s) => !s)} /></div>)}
            </div>
            {!servers ? (<div className='flex items-center justify-center h-96'><Spinner size={'large'} /></div>) : (
                <Pagination data={servers} onPageSelect={setPage}>
                    {({ items }) => items.length > 0 ? (<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10 animate-fade-up'>{items.map((server) => (<HazyServerCard key={server.uuid} server={server} />))}</div>) : (<div className='glass-heavy rounded-[3rem] p-24 text-center border border-white/10 animate-fade-up'><p className='text-slate-400 font-medium text-2xl'>No instances available.</p></div>)}
                </Pagination>
            )}
        </PageContentBlock>
    );
};
EOF

cat > resources/scripts/components/hazy/HazyNavbar.tsx <<'EOF'
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
EOF
cat > resources/scripts/components/hazy/HazyServerCard.tsx <<'EOF'
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
EOF

cat > resources/scripts/components/server/console/ServerConsoleContainer.tsx <<'EOF'
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
EOF
cat > resources/scripts/components/hazy/elements/HazyResourceGraph.tsx <<'EOF'
import React from 'react';
import { motion } from 'framer-motion';
import { useStoreState } from 'easy-peasy';
const HazyResourceGraph = ({ label, value, color, icon: Icon }: any) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    return (
        <div className='glass rounded-[2rem] p-8 border border-white/5 relative overflow-hidden group transition-all duration-500 hover:border-white/10'>
            <div className='absolute top-0 right-0 p-10 opacity-5 group-hover:opacity-10 transition-opacity'><Icon size={100} style={{ color: color || primaryColor }} /></div>
            <div className='relative z-10'>
                <div className='flex items-center space-x-4 mb-6'>
                    <div className='p-3 rounded-2xl bg-white/5' style={{ color: color || primaryColor }}><Icon size={20} /></div>
                    <span className='text-[10px] font-black uppercase tracking-[0.3em] text-slate-500'>{label}</span>
                </div>
                <div className='flex items-baseline space-x-2'><span className='text-5xl font-black text-white tracking-tighter'>{value}</span><span className='text-sm font-bold text-slate-500'>%</span></div>
                <div className='mt-8 h-2 w-full bg-white/5 rounded-full overflow-hidden'>
                    <motion.div initial={{ width: 0 }} animate={{ width: `${Math.min(value || 0, 100)}%` }} transition={{ duration: 1.5, ease: [0.16, 1, 0.3, 1] }} className='h-full shadow-lg' style={{ backgroundColor: color || primaryColor, boxShadow: `0 0 25px ${(color || primaryColor)}80` }} />
                </div>
            </div>
        </div>
    );
};
export default HazyResourceGraph;
EOF

cat > resources/scripts/components/server/console/StatGraphs.tsx <<'EOF'
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
EOF

cat > resources/scripts/components/server/console/Console.tsx <<'EOF'
import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import SpinnerOverlay from '@/components/elements/SpinnerOverlay';
import { ServerContext } from '@/state/server';
import { usePermissions } from '@/plugins/usePermissions';
import useEventListener from '@/plugins/useEventListener';
import { debounce } from 'debounce';
import { usePersistedState } from '@/plugins/usePersistedState';
import { SocketEvent, SocketRequest } from '@/components/server/events';
import { ChevronDoubleRightIcon } from '@heroicons/react/solid';
import 'xterm/css/xterm.css';
import styles from './style.module.css';
const tTheme = { background: 'transparent', cursor: 'rgba(255, 255, 255, 0.5)', black: '#000000', red: '#ef4444', green: '#10b981', yellow: '#f59e0b', blue: '#3b82f6', magenta: '#8b5cf6', cyan: '#06b6d4', white: '#f8fafc', brightBlack: '#475569', brightRed: '#f87171', brightGreen: '#34d399', brightYellow: '#fbbf24', brightBlue: '#60a5fa', brightMagenta: '#a78bfa', brightCyan: '#22d3ee', brightWhite: '#ffffff', selection: 'rgba(167, 139, 250, 0.3)' };
export default () => {
    const TERMINAL_PRELUDE = '\u001b[1m\u001b[38;5;147mcontainer@hazy~ \u001b[0m';
    const ref = useRef<HTMLDivElement>(null);
    const terminal = useMemo(() => new Terminal({ disableStdin: true, cursorStyle: 'block', cursorBlink: true, allowTransparency: true, fontSize: 13, fontFamily: '"JetBrains Mono", monospace', rows: 35, theme: tTheme }), []);
    const fitAddon = new FitAddon();
    const { connected, instance } = ServerContext.useStoreState((state) => state.socket);
    const [canSendCommands] = usePermissions(['control.console']);
    const serverId = ServerContext.useStoreState((state) => state.server.data!.id);
    const [history, setHistory] = usePersistedState<string[]>(`${serverId}:command_history`, []);
    const [historyIndex, setHistoryIndex] = useState(-1);
    const hCO = (line: string, p = false) => terminal.writeln((p ? TERMINAL_PRELUDE : '') + line.replace(/(?:\r\n|\r|\n)$/im, '') + '\u001b[0m');
    const hCKD = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'ArrowUp') { const n = Math.min(historyIndex + 1, history!.length - 1); setHistoryIndex(n); e.currentTarget.value = history![n] || ''; e.preventDefault(); }
        else if (e.key === 'ArrowDown') { const n = Math.max(historyIndex - 1, -1); setHistoryIndex(n); e.currentTarget.value = history![n] || ''; }
        const c = e.currentTarget.value; if (e.key === 'Enter' && c.length > 0) { setHistory((p) => [c, ...p!].slice(0, 32)); setHistoryIndex(-1); instance && instance.send('send command', c); e.currentTarget.value = ''; }
    };
    useEffect(() => { if (connected && ref.current && !terminal.element) { terminal.loadAddon(fitAddon); terminal.open(ref.current); fitAddon.fit(); } }, [terminal, connected]);
    useEventListener('resize', debounce(() => terminal.element && fitAddon.fit(), 100));
    useEffect(() => {
        const l: Record<string, (s: string) => void> = { [SocketEvent.STATUS]: (s) => terminal.writeln(TERMINAL_PRELUDE + '\u001b[1m\u001b[38;5;159mStatus: ' + s + '...\u001b[0m'), [SocketEvent.CONSOLE_OUTPUT]: hCO, [SocketEvent.INSTALL_OUTPUT]: hCO, [SocketEvent.DAEMON_MESSAGE]: (line) => hCO(line, true) };
        if (connected && instance) { terminal.clear(); Object.keys(l).forEach((k) => instance.addListener(k, l[k])); instance.send(SocketRequest.SEND_LOGS); }
        return () => { if (instance) Object.keys(l).forEach((k) => instance.removeListener(k, l[k])); };
    }, [connected, instance]);
    return (<div className='relative'><SpinnerOverlay visible={!connected} size={'large'} /><div className='p-6 bg-black/20'><div id={styles.terminal} ref={ref} /></div>
            {canSendCommands && (<div className='relative mt-1 px-6 pb-6 bg-black/20'><div className='relative flex items-center group'><div className='absolute left-4 text-violet-400 group-focus-within:text-white'><ChevronDoubleRightIcon className='w-4 h-4' /></div>
                <input className='w-full pl-12 pr-4 py-3 bg-white/5 border border-white/5 rounded-xl focus:outline-none focus:border-violet-500/50 transition-all text-sm font-mono text-slate-200' type='text' placeholder='Enter command...' disabled={!instance || !connected} onKeyDown={hCKD} /></div></div>)}</div>);
};
EOF
cat > resources/scripts/components/server/console/PowerButtons.tsx <<'EOF'
import React, { useEffect, useState } from 'react';
import Can from '@/components/elements/Can';
import { ServerContext } from '@/state/server';
import { Dialog } from '@/components/elements/dialog';
import HazyButton from '@/components/hazy/elements/HazyButton';
import { Power, RefreshCw, Square } from 'lucide-react';
export default ({ className }: { className?: string }) => {
    const [open, setOpen] = useState(false);
    const status = ServerContext.useStoreState((state) => state.status.value);
    const instance = ServerContext.useStoreState((state) => state.socket.instance);
    const killable = status === 'stopping';
    const onButtonClick = (a: any, e: any): void => { e.preventDefault(); if (a === 'kill') return setOpen(true); if (instance) { setOpen(false); instance.send('set state', a === 'kill-confirmed' ? 'kill' : a); } };
    useEffect(() => { if (status === 'offline') setOpen(false); }, [status]);
    return (
        <div className={className}>
            <Dialog.Confirm open={open} hideCloseIcon onClose={() => setOpen(false)} title={'Forcibly Stop Process'} confirm={'Continue'} onConfirmed={onButtonClick.bind(this, 'kill-confirmed')}>Forcibly stopping a server can lead to data corruption.</Dialog.Confirm>
            <Can action={'control.start'}><HazyButton variant='primary' disabled={status !== 'offline'} onClick={onButtonClick.bind(this, 'start')} className='px-4'><Power size={18} /><span>Start</span></HazyButton></Can>
            <Can action={'control.restart'}><HazyButton variant='glass' disabled={!status} onClick={onButtonClick.bind(this, 'restart')} className='px-4'><RefreshCw size={18} /><span>Restart</span></HazyButton></Can>
            <Can action={'control.stop'}><HazyButton variant='danger' disabled={status === 'offline'} onClick={onButtonClick.bind(this, killable ? 'kill' : 'stop')} className='px-4'><Square size={18} /><span>{killable ? 'Kill' : 'Stop'}</span></HazyButton></Can>
        </div>
    );
};
EOF

cat > resources/scripts/components/hazy/elements/HazyButton.tsx <<'EOF'
import React from 'react';
import { motion } from 'framer-motion';
import { Loader2 } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
const HazyButton = ({ variant = 'primary', isLoading, children, className = '', ...props }: any) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    const v: any = { primary: 'text-white', secondary: 'bg-slate-800 text-slate-200', danger: 'bg-red-600 text-white', glass: 'glass text-white' };
    const style = variant === 'primary' ? { backgroundColor: primaryColor, boxShadow: `0 25px 50px -12px ${primaryColor}66` } : {};
    return (<motion.button whileTap={{ scale: 0.9 }} className={`relative px-10 py-4 rounded-3xl font-black uppercase tracking-[0.2em] text-[10px] transition-all flex items-center justify-center space-x-4 disabled:opacity-50 ${v[variant] || v.primary} ${className}`} style={style} disabled={isLoading} {...props}>{isLoading && <Loader2 size={20} className='animate-spin' />}<span className={isLoading ? 'opacity-0' : 'opacity-100'}>{children}</span></motion.button>);
};
export default HazyButton;
EOF
cat > resources/scripts/components/server/console/ServerDetailsBlock.tsx <<'EOF'
import React, { useEffect, useState } from 'react';
import { bytesToString, ip } from '@/lib/formatters';
import { ServerContext } from '@/state/server';
import { SocketEvent, SocketRequest } from '@/components/server/events';
import useWebsocketEvent from '@/plugins/useWebsocketEvent';
import { Wifi, Activity, Shield } from 'lucide-react';
const DetailRow = ({ label, value, icon: Icon, color }: any) => (
    <div className='flex items-center justify-between py-5 border-b border-white/5 last:border-0 group'>
        <div className='flex items-center space-x-4'>
            <div className='p-3 rounded-2xl bg-white/5 text-slate-500 group-hover:text-white transition-colors' style={{ color }}><Icon size={18} /></div>
            <span className='text-[10px] font-black text-slate-500 uppercase tracking-[0.2em]'>{label}</span>
        </div>
        <span className='text-sm font-black text-slate-100 tracking-tight'>{value}</span>
    </div>
);
const ServerDetailsBlock = () => {
    const [stats, setStats] = useState<any>({ rx: 0, tx: 0 });
    const status = ServerContext.useStoreState((state) => state.status.value);
    const { connected, instance } = ServerContext.useStoreState((state) => state.socket);
    const allocation = ServerContext.useStoreState((state) => {
        const match = state.server.data!.allocations.find((a) => a.isDefault);
        return !match ? 'n/a' : `${match.alias || ip(match.ip)}:${match.port}`;
    });
    useEffect(() => { if (connected && instance) instance.send(SocketRequest.SEND_STATS); }, [instance, connected]);
    useWebsocketEvent(SocketEvent.STATS, (data) => { try { const s = JSON.parse(data); setStats({ rx: s.network.rx_bytes, tx: s.network.tx_bytes }); } catch (e) {} });
    return (<div className='space-y-2'>
            <DetailRow label='Endpoint' value={allocation} icon={Wifi} />
            <DetailRow label='State' value={status || 'Offline'} icon={Activity} color={status === 'running' ? '#10b981' : '#ef4444'} />
            <DetailRow label='Traffic In' value={bytesToString(stats.rx)} icon={Shield} color='#3b82f6' />
            <DetailRow label='Traffic Out' value={bytesToString(stats.tx)} icon={Shield} color='#f59e0b' />
        </div>);
};
export default ServerDetailsBlock;
EOF

cat > resources/scripts/components/hazy/elements/HazyToast.tsx <<'EOF'
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
EOF

cat > resources/scripts/components/hazy/elements/HazyModal.tsx <<'EOF'
import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';
const HazyModal = ({ visible, onClose, title, children }: any) => {
    useEffect(() => { const h = (e: any) => e.key === 'Escape' && onClose(); window.addEventListener('keydown', h); return () => window.removeEventListener('keydown', h); }, [onClose]);
    return (<AnimatePresence>{visible && (<div className='fixed inset-0 z-[100] flex items-center justify-center p-4'><motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} onClick={onClose} className='absolute inset-0 bg-slate-950/60 backdrop-blur-sm' /><motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }} transition={{ type: 'spring', damping: 25 }} className='relative w-full max-w-lg glass-heavy rounded-3xl shadow-2xl border border-white/10 overflow-hidden'><div className='p-6 border-b border-white/5 flex items-center justify-between'><h3 className='text-xl font-bold text-slate-100'>{title}</h3><button onClick={onClose} className='p-2 hover:bg-white/5 rounded-full text-slate-400 transition-colors'><X size={20} /></button></div><div className='p-6 text-slate-300'>{children}</div></motion.div></div>)}</AnimatePresence>);
};
export default HazyModal;
EOF
cat > resources/scripts/components/server/console/ChartBlock.tsx <<'EOF'
import React from 'react';
interface ChartBlockProps { title: string; legend?: React.ReactNode; children: React.ReactNode; }
export default ({ title, legend, children }: ChartBlockProps) => (
    <div className='glass rounded-3xl p-6 border border-white/5 transition-all duration-300 hover:border-white/10 group'>
        <div className='flex items-center justify-between mb-6'>
            <h3 className='text-xs font-black text-slate-500 uppercase tracking-widest group-hover:text-slate-300 transition-colors'>{title}</h3>
            {legend && <div className='flex items-center space-x-2'>{legend}</div>}
        </div>
        <div className='relative h-[200px]'>{children}</div>
    </div>
);
EOF

cat > resources/scripts/components/server/console/StatBlock.tsx <<'EOF'
import React from 'react';
import { useStoreState } from 'easy-peasy';
const StatBlock = ({ title, value, icon: Icon, color }: any) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    return (
        <div className='glass rounded-3xl p-6 border border-white/5 relative overflow-hidden group'>
            <div className='absolute -right-4 -bottom-4 opacity-5 group-hover:opacity-10 transition-opacity'><Icon size={120} style={{ color: color || primaryColor }} /></div>
            <div className='relative z-10'>
                <div className='flex items-center space-x-3 mb-4'><div className='p-2 rounded-xl bg-white/5' style={{ color: color || primaryColor }}><Icon size={18} /></div><span className='text-[10px] font-black uppercase tracking-widest text-slate-500'>{title}</span></div>
                <div className='text-3xl font-black text-white tracking-tighter truncate'>{value}</div>
            </div>
        </div>
    );
};
export default StatBlock;
EOF

echo "🛠️ 3/5 Patching Core..."
grep -q "admin.settings.hazytheme" resources/views/partials/admin/settings/nav.blade.php || sed -i "/admin.settings.advanced/a \                    <li @if(\$activeTab === 'hazytheme')class=\"active\"@endif><a href=\"{{ route('admin.settings.hazytheme') }}\">HazyTheme</a></li>" resources/views/partials/admin/settings/nav.blade.php
if ! grep -q "admin.settings.hazytheme" routes/admin.php; then
    sed -i "/Route::patch('\/advanced'/a \    Route::get('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'index'])->name('admin.settings.hazytheme');\n    Route::patch('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'update']);" routes/admin.php
fi

sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/ServerRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/ServerRouter.tsx

echo "🚀 4/5 Building Assets..."
yarn install --ignore-engines
export NODE_OPTIONS=--max_old_space_size=4096
yarn build:production

echo "🧹 5/5 Clearing Cache..."
php artisan view:clear
php artisan config:clear

echo "✨ HazyTheme ULTRA Activated! Refresh your browser."

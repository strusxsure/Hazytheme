cat > install-hazy.sh <<'EOF_OUTER'
#!/bin/bash
set -e
echo "🌫️ HazyTheme ULTRA Auto-Installer"

if [ ! -f artisan ]; then
    echo "❌ Error: Run this in /var/www/pterodactyl"
    (exit 1)
fi

echo "📦 Dependencies..."
sed -i 's/"lucide-react": "[^"]*"/"lucide-react": "^0.263.1"/g' package.json
grep -q "lucide-react" package.json || sed -i '/"dependencies": {/a \        "lucide-react": "^0.263.1",' package.json
sed -i 's/"react-circular-progressbar": "[^"]*"/"react-circular-progressbar": "^2.1.0"/g' package.json
grep -q "react-circular-progressbar" package.json || sed -i '/"dependencies": {/a \        "react-circular-progressbar": "^2.1.0",' package.json

mkdir -p resources/scripts/components/hazy/elements resources/scripts/css app/Http/Controllers/Admin/Settings resources/views/admin/settings

echo "✍️ Writing Files..."
EOF_OUTER

# Append CSS
cat >> install-hazy.sh <<'EOF_OUTER'
cat > resources/scripts/css/hazytheme.css <<'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500&display=swap');
:root { --hazy-primary: #a78bfa; --hazy-secondary: #8b5cf6; --hazy-danger: #ef4444; --hazy-success: #10b981; --hazy-warning: #f59e0b; --hazy-info: #3b82f6; --hazy-bg: #0f172a; --hazy-sidebar: rgba(15, 23, 42, 0.8); --hazy-card: rgba(30, 41, 59, 0.5); --hazy-navbar: rgba(15, 23, 42, 0.6); --hazy-accent: #c4b5fd; --hazy-text: #f8fafc; --hazy-text-muted: #94a3b8; --hazy-glass-border: rgba(255, 255, 255, 0.1); }
body { background-color: var(--hazy-bg) !important; color: var(--hazy-text) !important; font-family: 'Inter', sans-serif !important; overflow-x: hidden; min-height: 100vh; }
.glass { background: rgba(255, 255, 255, 0.05); backdrop-filter: blur(12px); -webkit-backdrop-filter: blur(12px); border: 1px solid var(--hazy-glass-border); }
.glass-heavy { background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(24px); -webkit-backdrop-filter: blur(24px); border: 1px solid var(--hazy-glass-border); }
.glass-light { background: rgba(255, 255, 255, 0.02); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); border: 1px solid var(--hazy-glass-border); }
@keyframes fade-up { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
.animate-fade-up { animation: fade-up 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
.status-online { animation: breathing-glow 2s infinite ease-in-out; }
@keyframes breathing-glow { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.6; transform: scale(1.1); } }
.hazy-orb-1, .hazy-orb-2, .hazy-orb-3 { position: fixed; border-radius: 50%; filter: blur(120px); z-index: -1; opacity: 0.5; pointer-events: none; }
.hazy-orb-1 { width: 600px; height: 600px; background: radial-gradient(circle, var(--hazy-primary) 0%, transparent 70%); top: -200px; right: -200px; }
.hazy-orb-2 { width: 700px; height: 700px; background: radial-gradient(circle, #8b5cf6 0%, transparent 70%); bottom: -250px; left: -250px; }
.hazy-orb-3 { width: 400px; height: 400px; background: radial-gradient(circle, #3b82f6 0%, transparent 70%); top: 40%; left: 10%; }
div[class*="PageContentBlock"] { background: transparent !important; }
div[class*="ContentContainer"] { max-width: 1400px !important; padding: 2rem !important; }
EOF
EOF_OUTER

# Append Dashboard
cat >> install-hazy.sh <<'EOF_OUTER'
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
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            <div className='flex flex-col md:flex-row justify-between items-start md:items-center mb-10 gap-4'>
                <div><h1 className='text-5xl font-black text-white tracking-tighter mb-2'>Dashboard</h1><p className='text-slate-400 font-medium'>Control your digital empire.</p></div>
                {rootAdmin && (<div className='glass-light px-5 py-2 rounded-2xl flex items-center border border-white/5'><p className='uppercase text-[10px] font-black text-slate-400 mr-3 tracking-widest'>{showOnlyAdmin ? "Viewing Others' Servers" : "Viewing Your Servers"}</p><Switch name={'show_all_servers'} defaultChecked={showOnlyAdmin} onChange={() => setShowOnlyAdmin((s) => !s)} /></div>)}
            </div>
            {!servers ? (<div className='flex items-center justify-center h-64'><Spinner size={'large'} /></div>) : (
                <Pagination data={servers} onPageSelect={setPage}>
                    {({ items }) => items.length > 0 ? (
                        <div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 animate-fade-up'>{items.map((server) => (<HazyServerCard key={server.uuid} server={server} />))}</div>
                    ) : (<div className='glass-heavy rounded-[2.5rem] p-20 text-center border border-white/10'><p className='text-slate-400 font-medium text-xl'>No servers found.</p></div>)}
                </Pagination>
            )}
        </PageContentBlock>
    );
};
EOF
EOF_OUTER

# Append Server Card
cat >> install-hazy.sh <<'EOF_OUTER'
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
        <motion.div whileHover={{ y: -10, scale: 1.02 }} className='group glass rounded-[2.5rem] p-8 transition-all duration-500 hover:shadow-2xl hover:shadow-violet-500/20' style={{ borderColor: `${primaryColor}22` } as any}>
            <Link to={`/server/${server.id}`} className='block'>
                <div className='flex justify-between items-start mb-10'>
                    <div className='flex items-center space-x-5'>
                        <div className='p-5 rounded-[1.5rem] transition-all duration-500 group-hover:scale-110' style={{ backgroundColor: `${primaryColor}1a`, color: primaryColor }}><ServerIcon size={32} /></div>
                        <div><h3 className='text-2xl font-black text-white group-hover:text-violet-400 transition-colors truncate max-w-[200px]'>{server.name}</h3><div className='flex items-center space-x-2 mt-2'><span className={`w-2.5 h-2.5 rounded-full ${stats?.status === 'running' ? 'bg-emerald-500 status-online' : 'bg-red-500'}`}></span><span className='text-[10px] text-slate-500 font-black uppercase tracking-widest'>{stats?.status || 'Offline'}</span></div></div>
                    </div><Power size={24} className='text-slate-600 group-hover:text-violet-400 transition-colors' />
                </div>
                <div className='grid grid-cols-3 gap-6'>
                    {[{l:'CPU',v:cpu,t:stats?.cpuUsagePercent.toFixed(0)+'%'},{l:'RAM',v:ram,t:stats?bytesToString(stats.memoryUsageInBytes):'0MB'},{l:'Disk',v:20,t:stats?bytesToString(stats.diskUsageInBytes):'0MB'}].map((x,i)=>(
                        <div key={i} className='flex flex-col items-center'><div className='w-16 h-16 mb-3'><CircularProgressbar value={x.v} strokeWidth={12} styles={buildStyles({pathColor:primaryColor,trailColor:'rgba(255,255,255,0.02)',strokeLinecap:'round'})}/></div><span className='text-[10px] text-slate-500 font-black uppercase tracking-widest'>{x.l}</span><span className='text-xs text-slate-300 font-bold mt-2'>{x.t}</span></div>
                    ))}
                </div>
            </Link>
        </motion.div>
    );
};
export default memo(HazyServerCard);
EOF
EOF_OUTER

# Append Console
cat >> install-hazy.sh <<'EOF_OUTER'
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
            <div className='animate-fade-up'>
                <div className='flex flex-col lg:flex-row justify-between items-start lg:items-center mb-10 gap-8'>
                    <div><h1 className='text-5xl font-black text-white tracking-tighter mb-2'>{name}</h1><p className='text-slate-400 font-medium text-lg'>{description}</p></div>
                    <div className='glass-light p-3 rounded-[1.5rem] border border-white/5'><Can action={['control.start', 'control.stop', 'control.restart']} matchAny><PowerButtons className={'flex space-x-4'} /></Can></div>
                </div>
                <div className='grid grid-cols-12 gap-8 mb-10'>
                    <div className='col-span-12 lg:col-span-9'><div className='glass-heavy rounded-[2.5rem] border border-white/10 overflow-hidden shadow-2xl shadow-black/50'><Spinner.Suspense><Console /></Spinner.Suspense></div></div>
                    <div className='col-span-12 lg:col-span-3'><div className='glass rounded-[2.5rem] p-8 border border-white/10 h-full'><h3 className='text-xs font-black text-slate-500 uppercase tracking-[0.2em] mb-8'>Environment</h3><ServerDetailsBlock /></div></div>
                </div>
                <div className='grid grid-cols-1 md:grid-cols-3 gap-8'><Spinner.Suspense><StatGraphs /></Spinner.Suspense></div>
            </div>
            <Features enabled={eggFeatures} />
        </ServerContentBlock>
    );
};
export default memo(ServerConsoleContainer, isEqual);
EOF
EOF_OUTER

# Final patching and build steps
cat >> install-hazy.sh <<'EOF_OUTER'
echo "🛠️ Patching..."
grep -q "admin.settings.hazytheme" resources/views/partials/admin/settings/nav.blade.php || sed -i "/admin.settings.advanced/a \                    <li @if(\$activeTab === 'hazytheme')class=\"active\"@endif><a href=\"{{ route('admin.settings.hazytheme') }}\">HazyTheme</a></li>" resources/views/partials/admin/settings/nav.blade.php
if ! grep -q "admin.settings.hazytheme" routes/admin.php; then
    sed -i "/Route::patch('\/advanced'/a \    Route::get('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'index'])->name('admin.settings.hazytheme');\n    Route::patch('/hazytheme', [Admin\\\\Settings\\\\HazyThemeController::class, 'update']);" routes/admin.php
fi
sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/DashboardRouter.tsx
sed -i "s/import NavigationBar from '@\/components\/NavigationBar';/import HazyNavbar from '@\/components\/hazy\/HazyNavbar';/g" resources/scripts/routers/ServerRouter.tsx
sed -i "s/<NavigationBar \/>/<HazyNavbar \/>/g" resources/scripts/routers/ServerRouter.tsx

echo "🚀 Building HazyTheme ULTRA... (This may take a few minutes)"
yarn install --ignore-engines
NODE_OPTIONS=--max_old_space_size=4096 yarn build:production
php artisan view:clear
php artisan config:clear
echo "✅ Done! Refresh with Ctrl+F5"
EOF_OUTER

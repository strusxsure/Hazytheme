import React, { useState, useEffect } from 'react';
import { NavLink } from 'react-router-dom';
import { motion } from 'framer-motion';
import { LayoutDashboard, User, ShieldAlert, LogOut, ChevronLeft, ChevronRight, Power, RefreshCw, Square } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
import http from '@/api/http';

const HazySidebar = () => {
    const [collapsed, setCollapsed] = useState(() =>
        JSON.parse(localStorage.getItem('hazy_sidebar_collapsed') || 'false')
    );
    const rootAdmin = useStoreState((state: any) => state.user.data?.rootAdmin);
    const username = useStoreState((state: any) => state.user.data?.username);
    const settings = useStoreState((state: any) => state.settings.data?.hazytheme);
    const primaryColor = settings?.primary_color || '#a78bfa';

    useEffect(() => {
        localStorage.setItem('hazy_sidebar_collapsed', JSON.stringify(collapsed));
    }, [collapsed]);

    const onLogout = () => {
        http.post('/auth/logout').finally(() => {
            window.location.href = '/';
        });
    };

    return (
        <motion.div
            initial={false}
            animate={{ width: collapsed ? 80 : 280 }}
            className='fixed left-0 top-0 h-screen glass-heavy z-50 flex flex-col border-r border-white/10'
        >
            <div className='p-6 flex items-center justify-between mb-10'>
                {!collapsed && (
                    <span className='text-3xl font-black bg-clip-text text-transparent' style={{ backgroundImage: `linear-gradient(to right, ${primaryColor}, #8b5cf6)` }}>
                        HAZY
                    </span>
                )}
                <button
                    onClick={() => setCollapsed(!collapsed)}
                    className='p-2 hover:bg-white/5 rounded-xl text-slate-400'
                >
                    {collapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
                </button>
            </div>

            <nav className='flex-1 px-4 space-y-3'>
                <NavLink
                    to='/'
                    exact
                    activeStyle={{ color: primaryColor, backgroundColor: `${primaryColor}1a` }}
                    className='flex items-center p-4 text-slate-400 hover:text-slate-200 rounded-2xl transition-all'
                >
                    <LayoutDashboard size={24} />
                    {!collapsed && <span className='ml-4 font-bold tracking-tight'>Dashboard</span>}
                </NavLink>
                <NavLink
                    to='/account'
                    activeStyle={{ color: primaryColor, backgroundColor: `${primaryColor}1a` }}
                    className='flex items-center p-4 text-slate-400 hover:text-slate-200 rounded-2xl transition-all'
                >
                    <User size={24} />
                    {!collapsed && <span className='ml-4 font-bold tracking-tight'>Account</span>}
                </NavLink>
                {rootAdmin && (
                    <a
                        href='/admin'
                        className='flex items-center p-4 text-slate-400 hover:text-slate-200 rounded-2xl transition-all'
                    >
                        <ShieldAlert size={24} />
                        {!collapsed && <span className='ml-4 font-bold tracking-tight'>Admin</span>}
                    </a>
                )}
            </nav>

            <div className='p-6 mt-auto border-t border-white/5 space-y-6'>
                {!collapsed && (
                    <div className='px-2 text-[10px] font-black uppercase tracking-[0.2em] text-slate-500'>
                        {username}
                    </div>
                )}
                <button
                    onClick={onLogout}
                    className='w-full flex items-center p-4 text-red-400 hover:bg-red-500/10 rounded-2xl transition-all'
                >
                    <LogOut size={24} />
                    {!collapsed && <span className='ml-4 font-bold tracking-tight'>Logout</span>}
                </button>
            </div>
        </motion.div>
    );
};

export default HazySidebar;

import React, { useState, useEffect } from 'react';
import { NavLink } from 'react-router-dom';
import { motion } from 'framer-motion';
import { LayoutDashboard, User, ShieldAlert, LogOut, ChevronLeft, ChevronRight } from 'lucide-react';
import { useStoreState } from 'easy-peasy';
import http from '@/api/http';

const HazySidebar = () => {
    const [collapsed, setCollapsed] = useState(() =>
        JSON.parse(localStorage.getItem('hazy_sidebar_collapsed') || 'false')
    );
    const rootAdmin = useStoreState((state: any) => state.user.data?.rootAdmin);
    const username = useStoreState((state: any) => state.user.data?.username);

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
            animate={{ width: collapsed ? 72 : 260 }}
            className='fixed left-0 top-0 h-screen glass-heavy z-50 flex flex-col border-r border-white/10'
        >
            <div className='p-4 flex items-center justify-between mb-8'>
                {!collapsed && (
                    <span className='text-xl font-bold bg-gradient-to-r from-violet-400 to-indigo-400 bg-clip-text text-transparent'>
                        HazyTheme
                    </span>
                )}
                <button
                    onClick={() => setCollapsed(!collapsed)}
                    className='p-2 hover:bg-white/5 rounded-lg text-slate-400'
                >
                    {collapsed ? <ChevronRight size={20} /> : <ChevronLeft size={20} />}
                </button>
            </div>

            <nav className='flex-1 px-2 space-y-2'>
                <NavLink
                    to='/'
                    exact
                    activeClassName='text-violet-400 bg-violet-500/10 !border-l-4 border-violet-400'
                    className='flex items-center p-3 text-slate-400 hover:text-violet-400 rounded-xl transition-all border-l-4 border-transparent'
                >
                    <LayoutDashboard size={24} className='min-w-[24px]' />
                    {!collapsed && <span className='ml-4 font-medium'>Dashboard</span>}
                </NavLink>
                <NavLink
                    to='/account'
                    activeClassName='text-violet-400 bg-violet-500/10 !border-l-4 border-violet-400'
                    className='flex items-center p-3 text-slate-400 hover:text-violet-400 rounded-xl transition-all border-l-4 border-transparent'
                >
                    <User size={24} className='min-w-[24px]' />
                    {!collapsed && <span className='ml-4 font-medium'>Account</span>}
                </NavLink>
                {rootAdmin && (
                    <a
                        href='/admin'
                        className='flex items-center p-3 text-slate-400 hover:text-violet-400 rounded-xl transition-all border-l-4 border-transparent'
                    >
                        <ShieldAlert size={24} className='min-w-[24px]' />
                        {!collapsed && <span className='ml-4 font-medium'>Admin</span>}
                    </a>
                )}
            </nav>

            <div className='p-4 mt-auto border-t border-white/5 space-y-4'>
                {!collapsed && <div className='px-2 text-sm font-semibold truncate text-slate-300'>{username}</div>}
                <button
                    onClick={onLogout}
                    className='w-full flex items-center p-3 text-red-400 hover:bg-red-500/10 rounded-xl transition-all'
                >
                    <LogOut size={24} className='min-w-[24px]' />
                    {!collapsed && <span className='ml-4 font-medium'>Logout</span>}
                </button>
            </div>
        </motion.div>
    );
};

export default HazySidebar;

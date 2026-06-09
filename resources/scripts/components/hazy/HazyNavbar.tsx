import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Search, Bell } from 'lucide-react';
import { useLocation, Link } from 'react-router-dom';

const HazyNavbar = () => {
    const location = useLocation();
    const [searchFocused, setSearchFocused] = useState(false);
    const pathSegments = location.pathname.split('/').filter(Boolean);

    return (
        <nav className="sticky top-0 w-full h-16 glass backdrop-blur-md border-b border-white/10 z-40 px-6 flex items-center justify-between">
            <div className="flex items-center space-x-2 text-sm text-slate-400">
                <Link to="/" className="hover:text-violet-400 transition-colors">Home</Link>
                {pathSegments.map((segment, index) => (
                    <React.Fragment key={index}>
                        <span className="mx-2 text-slate-600">/</span>
                        <span className="capitalize text-slate-200 font-medium">{segment.replace(/-/g, ' ')}</span>
                    </React.Fragment>
                ))}
            </div>

            <div className="flex items-center space-x-6">
                <motion.div animate={{ width: searchFocused ? 400 : 200 }} className="relative group">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-violet-400 transition-colors" size={18} />
                    <input
                        type="text"
                        placeholder="Search servers..."
                        onFocus={() => setSearchFocused(true)}
                        onBlur={() => setSearchFocused(false)}
                        className="w-full h-10 pl-10 pr-4 bg-white/5 border border-white/10 rounded-xl focus:outline-none focus:border-violet-500/50 transition-all text-sm text-slate-200"
                    />
                </motion.div>
                <div className="relative cursor-pointer text-slate-400 hover:text-violet-400 transition-colors">
                    <Bell size={22} />
                    <span className="absolute -top-1 -right-1 w-4 h-4 bg-violet-500 text-white text-[10px] flex items-center justify-center rounded-full border-2 border-slate-900 font-bold">3</span>
                </div>
            </div>
        </nav>
    );
};
export default HazyNavbar;

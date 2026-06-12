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

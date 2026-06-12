import React from 'react';
import { useStoreState } from 'easy-peasy';

interface StatBlockProps {
    title: string;
    value: string;
    icon: React.ComponentType<any>;
    color?: string;
}

const StatBlock = ({ title, value, icon: Icon, color }: StatBlockProps) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');

    return (
        <div className='glass rounded-3xl p-6 border border-white/5 relative overflow-hidden group'>
            <div className='absolute -right-4 -bottom-4 opacity-5 group-hover:opacity-10 transition-opacity'>
                <Icon size={120} style={{ color: color || primaryColor }} />
            </div>
            <div className='relative z-10'>
                <div className='flex items-center space-x-3 mb-4'>
                    <div className='p-2 rounded-xl bg-white/5' style={{ color: color || primaryColor }}>
                        <Icon size={18} />
                    </div>
                    <span className='text-[10px] font-black uppercase tracking-widest text-slate-500'>{title}</span>
                </div>
                <div className='text-3xl font-black text-white tracking-tighter truncate'>
                    {value}
                </div>
            </div>
        </div>
    );
};

export default StatBlock;

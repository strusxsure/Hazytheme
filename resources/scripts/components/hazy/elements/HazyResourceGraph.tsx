import React from 'react';
import { motion } from 'framer-motion';
import { useStoreState } from 'easy-peasy';

const HazyResourceGraph = ({ data }: { data: { cpu: number; ram: number; disk: number } }) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');

    return (
        <div className='space-y-4 w-full'>
            {(['cpu', 'ram', 'disk'] as const).map((k) => (
                <div key={k} className='space-y-1'>
                    <div className='flex justify-between text-[10px] font-bold text-slate-500 uppercase tracking-widest'>
                        <span>{k}</span>
                        <span>{data[k]?.toFixed(1)}%</span>
                    </div>
                    <div className='h-2 w-full bg-white/5 rounded-full overflow-hidden border border-white/5'>
                        <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${Math.min(data[k] || 0, 100)}%` }}
                            transition={{ duration: 1, ease: 'easeOut' }}
                            className='h-full shadow-[0_0_10px_rgba(167,139,250,0.5)]'
                            style={{ backgroundColor: primaryColor }}
                        />
                    </div>
                </div>
            ))}
        </div>
    );
};

export default HazyResourceGraph;

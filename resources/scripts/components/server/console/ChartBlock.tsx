import React from 'react';

interface ChartBlockProps {
    title: string;
    legend?: React.ReactNode;
    children: React.ReactNode;
}

export default ({ title, legend, children }: ChartBlockProps) => (
    <div className='glass rounded-3xl p-6 border border-white/5 transition-all duration-300 hover:border-white/10 group'>
        <div className='flex items-center justify-between mb-6'>
            <h3 className='text-xs font-black text-slate-500 uppercase tracking-widest group-hover:text-slate-300 transition-colors'>
                {title}
            </h3>
            {legend && <div className='flex items-center space-x-2'>{legend}</div>}
        </div>
        <div className='relative h-[200px]'>{children}</div>
    </div>
);

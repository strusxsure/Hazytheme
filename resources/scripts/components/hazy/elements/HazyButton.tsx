import React from 'react';
import { motion } from 'framer-motion';
import { Loader2 } from 'lucide-react';
import { useStoreState } from 'easy-peasy';

const HazyButton = ({ variant = 'primary', isLoading, children, className = '', ...props }: any) => {
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');

    const v: any = {
        primary: 'text-white shadow-lg',
        secondary: 'bg-slate-800 hover:bg-slate-700 text-slate-200 border border-white/5',
        danger: 'bg-red-600 hover:bg-red-500 text-white shadow-red-900/20',
        glass: 'glass hover:bg-white/10 text-white border-white/10',
    };

    const style = variant === 'primary' ? {
        backgroundColor: primaryColor,
        boxShadow: `0 10px 15px -3px ${primaryColor}33, 0 4px 6px -4px ${primaryColor}33`
    } : {};

    return (
        <motion.button
            whileTap={{ scale: 0.96 }}
            className={`relative px-6 py-2.5 rounded-xl font-semibold transition-all duration-200 flex items-center justify-center space-x-2 shadow-lg disabled:opacity-50 ${
                v[variant] || v.primary
            } ${className}`}
            style={style}
            disabled={isLoading}
            {...props}
        >
            {isLoading && <Loader2 size={18} className='animate-spin' />}
            <span className={isLoading ? 'opacity-0' : 'opacity-100'}>{children}</span>
        </motion.button>
    );
};

export default HazyButton;

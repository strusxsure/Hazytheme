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

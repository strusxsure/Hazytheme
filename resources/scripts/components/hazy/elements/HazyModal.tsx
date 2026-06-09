import React, { useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';

const HazyModal = ({ visible, onClose, title, children }: any) => {
    useEffect(() => {
        const h = (e: any) => e.key === 'Escape' && onClose();
        window.addEventListener('keydown', h);
        return () => window.removeEventListener('keydown', h);
    }, [onClose]);

    return (
        <AnimatePresence>
            {visible && (
                <div className='fixed inset-0 z-[100] flex items-center justify-center p-4'>
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        onClick={onClose}
                        className='absolute inset-0 bg-slate-950/60 backdrop-blur-sm'
                    />
                    <motion.div
                        initial={{ scale: 0.9, opacity: 0 }}
                        animate={{ scale: 1, opacity: 1 }}
                        exit={{ scale: 0.9, opacity: 0 }}
                        transition={{ type: 'spring', damping: 25 }}
                        className='relative w-full max-w-lg glass-heavy rounded-3xl shadow-2xl border border-white/10 overflow-hidden'
                    >
                        <div className='p-6 border-b border-white/5 flex items-center justify-between'>
                            <h3 className='text-xl font-bold text-slate-100'>{title}</h3>
                            <button
                                onClick={onClose}
                                className='p-2 hover:bg-white/5 rounded-full text-slate-400 transition-colors'
                            >
                                <X size={20} />
                            </button>
                        </div>
                        <div className='p-6 text-slate-300'>{children}</div>
                    </motion.div>
                </div>
            )}
        </AnimatePresence>
    );
};

export default HazyModal;

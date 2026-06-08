import React, { createContext, useContext, useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { CheckCircle } from 'lucide-react';

const ToastContext = createContext<any>(null);

export const ToastProvider = ({ children }: { children: React.ReactNode }) => {
    const [toasts, setToasts] = useState<any[]>([]);
    const addToast = useCallback((type: string, message: string) => {
        const id = Math.random().toString(36).substr(2, 9);
        setToasts(prev => [...prev, { id, message }]);
        setTimeout(() => setToasts(prev => prev.filter(t => t.id !== id)), 4000);
    }, []);

    return (
        <ToastContext.Provider value={{ addToast }}>
            {children}
            <div className="fixed bottom-6 right-6 z-[200] space-y-3 pointer-events-none">
                <AnimatePresence>
                    {toasts.map(t => (
                        <motion.div key={t.id} initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, scale: 0.9 }} className="pointer-events-auto min-w-[300px] glass-heavy border border-white/10 rounded-2xl p-4 shadow-2xl flex items-center space-x-4 relative overflow-hidden">
                            <div className="p-2 bg-white/5 rounded-xl text-emerald-400"><CheckCircle size={20} /></div>
                            <div className="flex-1 text-sm font-medium text-slate-200">{t.message}</div>
                        </motion.div>
                    ))}
                </AnimatePresence>
            </div>
        </ToastContext.Provider>
    );
};
export const useHazyToast = () => useContext(ToastContext);

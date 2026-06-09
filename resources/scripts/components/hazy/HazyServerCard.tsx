import React, { memo, useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import getServerResourceUsage from '@/api/server/getServerResourceUsage';
import { bytesToString } from '@/lib/formatters';
import { CircularProgressbar, buildStyles } from 'react-circular-progressbar';
import 'react-circular-progressbar/dist/styles.css';
import { Power, Server as ServerIcon } from 'lucide-react';
import { useStoreState } from 'easy-peasy';

const HazyServerCard = ({ server }: any) => {
    const [stats, setStats] = useState<any>(null);
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#6366f1');

    useEffect(() => {
        const f = () => getServerResourceUsage(server.uuid).then(setStats).catch(console.error);
        f();
        const i = setInterval(f, 10000);
        return () => clearInterval(i);
    }, [server.uuid]);

    const cpu = stats ? (stats.cpuUsagePercent / (server.limits.cpu || 100)) * 100 : 0;
    const ram = stats ? (stats.memoryUsageInBytes / (server.limits.memory * 1024 * 1024 || 1)) * 100 : 0;

    return (
        <motion.div
            whileHover={{ scale: 1.02, y: -5 }}
            className='group glass rounded-3xl p-6 border border-white/10 hover:border-violet-500/50 transition-all duration-300'
            style={{ '--tw-border-opacity': 1, borderColor: `${primaryColor}33` } as any}
        >
            <Link to={`/server/${server.id}`} className='block'>
                <div className='flex justify-between mb-8'>
                    <div className='flex items-center space-x-4'>
                        <div className='p-4 bg-violet-500/10 rounded-2xl transition-all duration-500' style={{ backgroundColor: `${primaryColor}1a`, color: primaryColor }}>
                            <ServerIcon size={28} />
                        </div>
                        <div>
                            <h3 className='text-xl font-bold text-slate-100 group-hover:text-violet-400 transition-colors truncate max-w-[180px]' style={{ '--tw-text-opacity': 1, color: undefined } as any}>
                                {server.name}
                            </h3>
                            <div className='flex items-center space-x-2 mt-1'>
                                <span
                                    className={`w-2 h-2 rounded-full ${
                                        stats?.status === 'running' ? 'bg-emerald-500 status-online' : 'bg-red-500'
                                    }`}
                                ></span>
                                <span className='text-xs text-slate-500 font-medium capitalize'>
                                    {stats?.status || 'Offline'}
                                </span>
                            </div>
                        </div>
                    </div>
                    <Power
                        size={22}
                        className='text-slate-500 hover:text-violet-400 transition-colors cursor-pointer'
                    />
                </div>
                <div className='grid grid-cols-3 gap-6'>
                    <div className='flex flex-col items-center'>
                        <div className='w-14 h-14 mb-2'>
                            <CircularProgressbar
                                value={cpu}
                                strokeWidth={10}
                                styles={buildStyles({
                                    pathColor: primaryColor,
                                    trailColor: 'rgba(255,255,255,0.03)',
                                    pathTransitionDuration: 1.5,
                                })}
                            />
                        </div>
                        <span className='text-[10px] text-slate-500 font-bold uppercase tracking-tighter'>CPU</span>
                        <span className='text-xs text-slate-300 font-medium mt-1'>
                            {stats?.cpuUsagePercent.toFixed(0)}%
                        </span>
                    </div>
                    <div className='flex flex-col items-center'>
                        <div className='w-14 h-14 mb-2'>
                            <CircularProgressbar
                                value={ram}
                                strokeWidth={10}
                                styles={buildStyles({
                                    pathColor: primaryColor,
                                    trailColor: 'rgba(255,255,255,0.03)',
                                    pathTransitionDuration: 1.5,
                                })}
                            />
                        </div>
                        <span className='text-[10px] text-slate-500 font-bold uppercase tracking-tighter'>RAM</span>
                        <span className='text-xs text-slate-300 font-medium mt-1'>
                            {stats ? bytesToString(stats.memoryUsageInBytes) : '0MB'}
                        </span>
                    </div>
                    <div className='flex flex-col items-center'>
                        <div className='w-14 h-14 mb-2'>
                            <CircularProgressbar
                                value={20}
                                strokeWidth={10}
                                styles={buildStyles({
                                    pathColor: primaryColor,
                                    trailColor: 'rgba(255,255,255,0.03)',
                                    pathTransitionDuration: 1.5,
                                })}
                            />
                        </div>
                        <span className='text-[10px] text-slate-500 font-bold uppercase tracking-tighter'>Disk</span>
                        <span className='text-xs text-slate-300 font-medium mt-1'>
                            {stats ? bytesToString(stats.diskUsageInBytes) : '0MB'}
                        </span>
                    </div>
                </div>
            </Link>
        </motion.div>
    );
};

export default memo(HazyServerCard);

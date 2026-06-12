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
    const primaryColor = useStoreState((state: any) => state.settings.data?.hazytheme?.primary_color || '#a78bfa');
    useEffect(() => { const f = () => getServerResourceUsage(server.uuid).then(setStats).catch(console.error); f(); const i = setInterval(f, 10000); return () => clearInterval(i); }, [server.uuid]);
    const cpu = stats ? (stats.cpuUsagePercent / (server.limits.cpu || 100)) * 100 : 0;
    const ram = stats ? (stats.memoryUsageInBytes / (server.limits.memory * 1024 * 1024 || 1)) * 100 : 0;
    return (
        <motion.div whileHover={{ y: -10, scale: 1.02 }} className='group glass rounded-[2.5rem] p-8 transition-all duration-500 hover:shadow-2xl hover:shadow-violet-500/20' style={{ borderColor: `${primaryColor}22` } as any}>
            <Link to={`/server/${server.id}`} className='block'>
                <div className='flex justify-between items-start mb-10'>
                    <div className='flex items-center space-x-5'>
                        <div className='p-5 rounded-[1.5rem] transition-all duration-500 group-hover:scale-110' style={{ backgroundColor: `${primaryColor}1a`, color: primaryColor }}><ServerIcon size={32} /></div>
                        <div><h3 className='text-2xl font-black text-white group-hover:text-violet-400 transition-colors truncate max-w-[200px]'>{server.name}</h3><div className='flex items-center space-x-2 mt-2'><span className={`w-2.5 h-2.5 rounded-full ${stats?.status === 'running' ? 'bg-emerald-500 status-online' : 'bg-red-500'}`}></span><span className='text-[10px] text-slate-500 font-black uppercase tracking-widest'>{stats?.status || 'Offline'}</span></div></div>
                    </div><Power size={24} className='text-slate-600 group-hover:text-violet-400 transition-colors' />
                </div>
                <div className='grid grid-cols-3 gap-6'>
                    {[{l:'CPU',v:cpu,t:stats?.cpuUsagePercent.toFixed(0)+'%'},{l:'RAM',v:ram,t:stats?bytesToString(stats.memoryUsageInBytes):'0MB'},{l:'Disk',v:20,t:stats?bytesToString(stats.diskUsageInBytes):'0MB'}].map((x,i)=>(
                        <div key={i} className='flex flex-col items-center'><div className='w-16 h-16 mb-3'><CircularProgressbar value={x.v} strokeWidth={12} styles={buildStyles({pathColor:primaryColor,trailColor:'rgba(255,255,255,0.02)',strokeLinecap:'round'})}/></div><span className='text-[10px] text-slate-500 font-black uppercase tracking-widest'>{x.l}</span><span className='text-xs text-slate-300 font-bold mt-2'>{x.t}</span></div>
                    ))}
                </div>
            </Link>
        </motion.div>
    );
};
export default memo(HazyServerCard);

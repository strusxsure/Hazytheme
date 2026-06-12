import React, { useEffect, useState } from 'react';
import { bytesToString, ip } from '@/lib/formatters';
import { ServerContext } from '@/state/server';
import { SocketEvent, SocketRequest } from '@/components/server/events';
import useWebsocketEvent from '@/plugins/useWebsocketEvent';
import { Wifi, Activity, Terminal as ConsoleIcon, Database, Shield } from 'lucide-react';
const DetailRow = ({ label, value, icon: Icon, color }: any) => (
    <div className='flex items-center justify-between py-5 border-b border-white/5 last:border-0 group'>
        <div className='flex items-center space-x-4'>
            <div className='p-3 rounded-2xl bg-white/5 text-slate-500 group-hover:text-white transition-colors' style={{ color }}><Icon size={18} /></div>
            <span className='text-[10px] font-black text-slate-500 uppercase tracking-[0.2em]'>{label}</span>
        </div>
        <span className='text-sm font-black text-slate-100 tracking-tight'>{value}</span>
    </div>
);
const ServerDetailsBlock = () => {
    const [stats, setStats] = useState<any>({ rx: 0, tx: 0 });
    const status = ServerContext.useStoreState((state) => state.status.value);
    const { connected, instance } = ServerContext.useStoreState((state) => state.socket);
    const allocation = ServerContext.useStoreState((state) => {
        const match = state.server.data!.allocations.find((a) => a.isDefault);
        return !match ? 'n/a' : `${match.alias || ip(match.ip)}:${match.port}`;
    });
    useEffect(() => { if (connected && instance) instance.send(SocketRequest.SEND_STATS); }, [instance, connected]);
    useWebsocketEvent(SocketEvent.STATS, (data) => { try { const s = JSON.parse(data); setStats({ rx: s.network.rx_bytes, tx: s.network.tx_bytes }); } catch (e) {} });
    return (<div className='space-y-2'>
            <DetailRow label='Endpoint' value={allocation} icon={Wifi} />
            <DetailRow label='State' value={status || 'Offline'} icon={Activity} color={status === 'running' ? '#10b981' : '#ef4444'} />
            <DetailRow label='Traffic In' value={bytesToString(stats.rx)} icon={Shield} color='#3b82f6' />
            <DetailRow label='Traffic Out' value={bytesToString(stats.tx)} icon={Shield} color='#f59e0b' />
        </div>);
};
export default ServerDetailsBlock;

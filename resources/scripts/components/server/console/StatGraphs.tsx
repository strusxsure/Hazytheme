import React, { useEffect, useRef } from 'react';
import { ServerContext } from '@/state/server';
import { SocketEvent } from '@/components/server/events';
import useWebsocketEvent from '@/plugins/useWebsocketEvent';
import HazyResourceGraph from '@/components/hazy/elements/HazyResourceGraph';
import { Cpu, Zap, HardDrive } from 'lucide-react';

export default () => {
    const status = ServerContext.useStoreState((state) => state.status.value);
    const limits = ServerContext.useStoreState((state) => state.server.data!.limits);
    const [stats, setStats] = React.useState({ cpu: 0, memory: 0, disk: 0 });

    useEffect(() => {
        if (status === 'offline') {
            setStats({ cpu: 0, memory: 0, disk: 0 });
        }
    }, [status]);

    useWebsocketEvent(SocketEvent.STATS, (data: string) => {
        let values: any = {};
        try { values = JSON.parse(data); } catch (e) { return; }

        setStats({
            cpu: values.cpu_absolute,
            memory: (values.memory_bytes / (limits.memory * 1024 * 1024)) * 100,
            disk: (values.disk_bytes / (limits.disk * 1024 * 1024)) * 100,
        });
    });

    return (
        <>
            <HazyResourceGraph label='CPU Load' value={stats.cpu.toFixed(1)} icon={Cpu} />
            <HazyResourceGraph label='Memory Usage' value={stats.memory.toFixed(1)} icon={Zap} color='#8b5cf6' />
            <HazyResourceGraph label='Disk Usage' value={stats.disk.toFixed(1)} icon={HardDrive} color='#3b82f6' />
        </>
    );
};

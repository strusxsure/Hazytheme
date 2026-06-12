import React, { memo } from 'react';
import { ServerContext } from '@/state/server';
import Can from '@/components/elements/Can';
import ServerContentBlock from '@/components/elements/ServerContentBlock';
import isEqual from 'react-fast-compare';
import Spinner from '@/components/elements/Spinner';
import Features from '@feature/Features';
import Console from '@/components/server/console/Console';
import StatGraphs from '@/components/server/console/StatGraphs';
import PowerButtons from '@/components/server/console/PowerButtons';
import ServerDetailsBlock from '@/components/server/console/ServerDetailsBlock';
const ServerConsoleContainer = () => {
    const name = ServerContext.useStoreState((state) => state.server.data!.name);
    const description = ServerContext.useStoreState((state) => state.server.data!.description);
    const eggFeatures = ServerContext.useStoreState((state) => state.server.data!.eggFeatures, isEqual);
    return (
        <ServerContentBlock title={'Console'}>
            <div className='animate-fade-up'>
                <div className='flex flex-col lg:flex-row justify-between items-start lg:items-center mb-10 gap-8'>
                    <div><h1 className='text-5xl font-black text-white tracking-tighter mb-2'>{name}</h1><p className='text-slate-400 font-medium text-lg'>{description}</p></div>
                    <div className='glass-light p-3 rounded-[1.5rem] border border-white/5'><Can action={['control.start', 'control.stop', 'control.restart']} matchAny><PowerButtons className={'flex space-x-4'} /></Can></div>
                </div>
                <div className='grid grid-cols-12 gap-8 mb-10'>
                    <div className='col-span-12 lg:col-span-9'><div className='glass-heavy rounded-[2.5rem] border border-white/10 overflow-hidden shadow-2xl shadow-black/50'><Spinner.Suspense><Console /></Spinner.Suspense></div></div>
                    <div className='col-span-12 lg:col-span-3'><div className='glass rounded-[2.5rem] p-8 border border-white/10 h-full'><h3 className='text-xs font-black text-slate-500 uppercase tracking-[0.2em] mb-8'>Environment</h3><ServerDetailsBlock /></div></div>
                </div>
                <div className='grid grid-cols-1 md:grid-cols-3 gap-8'><Spinner.Suspense><StatGraphs /></Spinner.Suspense></div>
            </div>
            <Features enabled={eggFeatures} />
        </ServerContentBlock>
    );
};
export default memo(ServerConsoleContainer, isEqual);

import React, { useEffect, useState } from 'react';
import getServers from '@/api/getServers';
import Spinner from '@/components/elements/Spinner';
import PageContentBlock from '@/components/elements/PageContentBlock';
import useFlash from '@/plugins/useFlash';
import { useStoreState } from 'easy-peasy';
import { usePersistedState } from '@/plugins/usePersistedState';
import Switch from '@/components/elements/Switch';
import useSWR from 'swr';
import { PaginatedResult } from '@/api/http';
import Pagination from '@/components/elements/Pagination';
import HazyServerCard from '@/components/hazy/HazyServerCard';
export default () => {
    const { search } = window.location;
    const defaultPage = Number(new URLSearchParams(search).get('page') || '1');
    const [page, setPage] = useState(!isNaN(defaultPage) && defaultPage > 0 ? defaultPage : 1);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const uuid = useStoreState((state) => state.user.data!.uuid);
    const rootAdmin = useStoreState((state) => state.user.data!.rootAdmin);
    const [showOnlyAdmin, setShowOnlyAdmin] = usePersistedState(`${uuid}:show_all_servers`, false);
    const { data: servers, error } = useSWR<PaginatedResult<any>>(['/api/client/servers', showOnlyAdmin && rootAdmin, page], () => getServers({ page, type: showOnlyAdmin && rootAdmin ? 'admin' : undefined }));
    useEffect(() => { setPage(1); }, [showOnlyAdmin]);
    useEffect(() => { if (error) clearAndAddHttpError({ key: 'dashboard', error }); if (!error) clearFlashes('dashboard'); }, [error]);
    return (
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            <div className='flex flex-col md:flex-row justify-between items-start md:items-center mb-16 gap-4 animate-fade-up'>
                <div><h1 className='text-6xl font-black text-white tracking-tighter mb-3'>Dashboard</h1><p className='text-slate-400 font-medium text-lg'>Overview of your high-performance nodes.</p></div>
                {rootAdmin && (<div className='glass-light px-6 py-3 rounded-2xl flex items-center border border-white/5'><p className='uppercase text-[10px] font-black text-slate-400 mr-4 tracking-widest'>{showOnlyAdmin ? "Viewing All Nodes" : "Viewing Your Nodes"}</p><Switch name={'show_all_servers'} defaultChecked={showOnlyAdmin} onChange={() => setShowOnlyAdmin((s) => !s)} /></div>)}
            </div>
            {!servers ? (<div className='flex items-center justify-center h-96'><Spinner size={'large'} /></div>) : (
                <Pagination data={servers} onPageSelect={setPage}>
                    {({ items }) => items.length > 0 ? (<div className='grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10 animate-fade-up'>{items.map((server) => (<HazyServerCard key={server.uuid} server={server} />))}</div>) : (<div className='glass-heavy rounded-[3rem] p-24 text-center border border-white/10 animate-fade-up'><p className='text-slate-400 font-medium text-2xl'>No instances available.</p></div>)}
                </Pagination>
            )}
        </PageContentBlock>
    );
};

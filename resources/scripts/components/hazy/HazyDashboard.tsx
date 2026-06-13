import React, { useEffect, useState } from 'react';
import { Server } from '@/api/server/getServer';
import getServers from '@/api/getServers';
import ServerRow from '@/components/dashboard/ServerRow';
import Pagination from '@/components/elements/Pagination';
import { useStoreState } from 'easy-peasy';
import { PaginatedResult } from '@/api/http';
import { useLocation } from 'react-router-dom';
import PageContentBlock from '@/components/elements/PageContentBlock';
export default () => {
    const { search } = useLocation();
    const [ servers, setServers ] = useState<PaginatedResult<Server>>();
    useEffect(() => { getServers({ query: search }).then(setServers); }, [ search ]);
    return (
        <PageContentBlock title={'Dashboard'} showFlashKey={'dashboard'}>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fade-up">
                {!servers ? (
                    <div className="col-span-full flex justify-center py-20"><div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-white"></div></div>
                ) : (
                    servers.data.map((server) => (
                        <div key={server.uuid} className="glass rounded-3xl p-1 transition-transform hover:scale-[1.02] duration-300">
                             <ServerRow server={server} className="!bg-transparent !border-0" />
                        </div>
                    ))
                )}
            </div>
            {servers && <Pagination data={servers} onPageSelect={() => {}} />}
        </PageContentBlock>
    );
};

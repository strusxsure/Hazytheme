import React, { useEffect, useState } from 'react';
import Can from '@/components/elements/Can';
import { ServerContext } from '@/state/server';
import { PowerAction } from '@/components/server/console/ServerConsoleContainer';
import { Dialog } from '@/components/elements/dialog';
import HazyButton from '@/components/hazy/elements/HazyButton';
import { Power, RefreshCw, Square } from 'lucide-react';

interface PowerButtonProps {
    className?: string;
}

export default ({ className }: PowerButtonProps) => {
    const [open, setOpen] = useState(false);
    const status = ServerContext.useStoreState((state) => state.status.value);
    const instance = ServerContext.useStoreState((state) => state.socket.instance);

    const killable = status === 'stopping';
    const onButtonClick = (
        action: PowerAction | 'kill-confirmed',
        e: React.MouseEvent<HTMLButtonElement, MouseEvent>
    ): void => {
        e.preventDefault();
        if (action === 'kill') {
            return setOpen(true);
        }

        if (instance) {
            setOpen(false);
            instance.send('set state', action === 'kill-confirmed' ? 'kill' : action);
        }
    };

    useEffect(() => {
        if (status === 'offline') {
            setOpen(false);
        }
    }, [status]);

    return (
        <div className={className}>
            <Dialog.Confirm
                open={open}
                hideCloseIcon
                onClose={() => setOpen(false)}
                title={'Forcibly Stop Process'}
                confirm={'Continue'}
                onConfirmed={onButtonClick.bind(this, 'kill-confirmed')}
            >
                Forcibly stopping a server can lead to data corruption.
            </Dialog.Confirm>
            <Can action={'control.start'}>
                <HazyButton
                    variant='primary'
                    disabled={status !== 'offline'}
                    onClick={onButtonClick.bind(this, 'start')}
                    className='px-4'
                >
                    <Power size={18} />
                    <span>Start</span>
                </HazyButton>
            </Can>
            <Can action={'control.restart'}>
                <HazyButton
                    variant='glass'
                    disabled={!status}
                    onClick={onButtonClick.bind(this, 'restart')}
                    className='px-4'
                >
                    <RefreshCw size={18} />
                    <span>Restart</span>
                </HazyButton>
            </Can>
            <Can action={'control.stop'}>
                <HazyButton
                    variant='danger'
                    disabled={status === 'offline'}
                    onClick={onButtonClick.bind(this, killable ? 'kill' : 'stop')}
                    className='px-4'
                >
                    <Square size={18} />
                    <span>{killable ? 'Kill' : 'Stop'}</span>
                </HazyButton>
            </Can>
        </div>
    );
};

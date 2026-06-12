import React, { useEffect, useMemo, useRef, useState } from 'react';
import { ITerminalOptions, Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import { SearchAddon } from 'xterm-addon-search';
import { SearchBarAddon } from 'xterm-addon-search-bar';
import { WebLinksAddon } from 'xterm-addon-web-links';
import { Unicode11Addon } from 'xterm-addon-unicode11';
import { ScrollDownHelperAddon } from '@/plugins/XtermScrollDownHelperAddon';
import SpinnerOverlay from '@/components/elements/SpinnerOverlay';
import { ServerContext } from '@/state/server';
import { usePermissions } from '@/plugins/usePermissions';
import { theme as th } from 'twin.macro';
import useEventListener from '@/plugins/useEventListener';
import { debounce } from 'debounce';
import { usePersistedState } from '@/plugins/usePersistedState';
import { SocketEvent, SocketRequest } from '@/components/server/events';
import classNames from 'classnames';
import { ChevronDoubleRightIcon } from '@heroicons/react/solid';

import 'xterm/css/xterm.css';
import styles from './style.module.css';

const terminalTheme = {
    background: 'transparent',
    cursor: 'rgba(255, 255, 255, 0.5)',
    black: '#000000',
    red: '#ef4444',
    green: '#10b981',
    yellow: '#f59e0b',
    blue: '#3b82f6',
    magenta: '#8b5cf6',
    cyan: '#06b6d4',
    white: '#f8fafc',
    brightBlack: '#475569',
    brightRed: '#f87171',
    brightGreen: '#34d399',
    brightYellow: '#fbbf24',
    brightBlue: '#60a5fa',
    brightMagenta: '#a78bfa',
    brightCyan: '#22d3ee',
    brightWhite: '#ffffff',
    selection: 'rgba(167, 139, 250, 0.3)',
};

const terminalProps: ITerminalOptions = {
    disableStdin: true,
    cursorStyle: 'block',
    cursorBlink: true,
    allowTransparency: true,
    fontSize: 13,
    fontFamily: '"JetBrains Mono", monospace',
    rows: 35,
    theme: terminalTheme,
};

export default () => {
    const TERMINAL_PRELUDE = '\u001b[1m\u001b[38;5;147mcontainer@hazy~ \u001b[0m';
    const ref = useRef<HTMLDivElement>(null);
    const terminal = useMemo(() => new Terminal({ ...terminalProps }), []);
    const fitAddon = new FitAddon();
    const { connected, instance } = ServerContext.useStoreState((state) => state.socket);
    const [canSendCommands] = usePermissions(['control.console']);
    const serverId = ServerContext.useStoreState((state) => state.server.data!.id);
    const isTransferring = ServerContext.useStoreState((state) => state.server.data!.isTransferring);
    const [history, setHistory] = usePersistedState<string[]>(`${serverId}:command_history`, []);
    const [historyIndex, setHistoryIndex] = useState(-1);

    const handleConsoleOutput = (line: string, prelude = false) =>
        terminal.writeln((prelude ? TERMINAL_PRELUDE : '') + line.replace(/(?:\r\n|\r|\n)$/im, '') + '\u001b[0m');

    const handleCommandKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
        if (e.key === 'ArrowUp') {
            const newIndex = Math.min(historyIndex + 1, history!.length - 1);
            setHistoryIndex(newIndex);
            e.currentTarget.value = history![newIndex] || '';
            e.preventDefault();
        } else if (e.key === 'ArrowDown') {
            const newIndex = Math.max(historyIndex - 1, -1);
            setHistoryIndex(newIndex);
            e.currentTarget.value = history![newIndex] || '';
        }

        const command = e.currentTarget.value;
        if (e.key === 'Enter' && command.length > 0) {
            setHistory((prev) => [command, ...prev!].slice(0, 32));
            setHistoryIndex(-1);
            instance && instance.send('send command', command);
            e.currentTarget.value = '';
        }
    };

    useEffect(() => {
        if (connected && ref.current && !terminal.element) {
            terminal.loadAddon(fitAddon);
            terminal.open(ref.current);
            fitAddon.fit();
        }
    }, [terminal, connected]);

    useEventListener('resize', debounce(() => terminal.element && fitAddon.fit(), 100));

    useEffect(() => {
        const listeners: Record<string, (s: string) => void> = {
            [SocketEvent.STATUS]: (s) => terminal.writeln(TERMINAL_PRELUDE + '\u001b[1m\u001b[38;5;159mStatus changed to ' + s + '...\u001b[0m'),
            [SocketEvent.CONSOLE_OUTPUT]: handleConsoleOutput,
            [SocketEvent.INSTALL_OUTPUT]: handleConsoleOutput,
            [SocketEvent.DAEMON_MESSAGE]: (line) => handleConsoleOutput(line, true),
        };

        if (connected && instance) {
            if (!isTransferring) terminal.clear();
            Object.keys(listeners).forEach((k) => instance.addListener(k, listeners[k]));
            instance.send(SocketRequest.SEND_LOGS);
        }

        return () => { if (instance) Object.keys(listeners).forEach((k) => instance.removeListener(k, listeners[k])); };
    }, [connected, instance]);

    return (
        <div className='relative'>
            <SpinnerOverlay visible={!connected} size={'large'} />
            <div className='p-6 bg-black/20'>
                <div id={styles.terminal} ref={ref} />
            </div>
            {canSendCommands && (
                <div className='relative mt-1 px-6 pb-6 bg-black/20'>
                    <div className='relative flex items-center group'>
                        <div className='absolute left-4 text-violet-400 group-focus-within:text-white transition-colors'><ChevronDoubleRightIcon className='w-4 h-4' /></div>
                        <input
                            className='w-full pl-12 pr-4 py-3 bg-white/5 border border-white/5 rounded-xl focus:outline-none focus:border-violet-500/50 transition-all text-sm font-mono text-slate-200'
                            type='text'
                            placeholder='Enter command...'
                            disabled={!instance || !connected}
                            onKeyDown={handleCommandKeyDown}
                        />
                    </div>
                </div>
            )}
        </div>
    );
};

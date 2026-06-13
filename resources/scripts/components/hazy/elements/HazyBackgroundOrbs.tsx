import React from 'react';
import { useStoreState } from 'easy-peasy';
const HazyBackgroundOrbs = () => {
    const isAnimated = useStoreState((state: any) => state.settings.data?.hazytheme?.animation !== 'false');
    if (!isAnimated) return null;
    return (
        <div className="fixed inset-0 pointer-events-none -z-10 overflow-hidden">
            <div className="hazy-orb-1" /><div className="hazy-orb-2" /><div className="hazy-orb-3" />
        </div>
    );
};
export default HazyBackgroundOrbs;

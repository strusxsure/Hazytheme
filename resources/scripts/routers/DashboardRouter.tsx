import React from 'react';
import { Route, Switch } from 'react-router-dom';
import DashboardContainer from '@/components/dashboard/DashboardContainer';
import HazyDashboard from '@/components/hazy/HazyDashboard';
import { NotFound } from '@/components/elements/ScreenBlock';
import { useRouteMatch } from 'react-router-dom';

export default () => {
    const { path } = useRouteMatch();
    return (
        <Switch>
            <Route path={path} exact>
                <HazyDashboard />
            </Route>
            <Route path={`${path}*`}>
                <NotFound />
            </Route>
        </Switch>
    );
};

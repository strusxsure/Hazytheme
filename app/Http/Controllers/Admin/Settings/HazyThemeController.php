<?php

namespace Pterodactyl\Http\Controllers\Admin\Settings;

use Illuminate\View\View;
use Illuminate\Http\Request;
use Illuminate\Http\RedirectResponse;
use Prologue\Alerts\AlertsMessageBag;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class HazyThemeController extends Controller
{
    public function __construct(
        private AlertsMessageBag $alert,
        private SettingsRepositoryInterface $settings,
    ) {
    }

    public function index(): View
    {
        return view('admin.settings.hazytheme', [
            'hazy_primary' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
            'hazy_animation' => $this->settings->get('hazytheme::animation', 'true'),
            'hazy_sidebar_power' => $this->settings->get('hazytheme::sidebar_power', 'true'),
            'hazy_dark_mode' => $this->settings->get('hazytheme::dark_mode', 'true'),
        ]);
    }

    public function update(Request $request): RedirectResponse
    {
        $this->settings->set('hazytheme::primary_color', $request->input('hazytheme::primary_color'));
        $this->settings->set('hazytheme::animation', $request->input('hazytheme::animation'));
        $this->settings->set('hazytheme::sidebar_power', $request->input('hazytheme::sidebar_power'));
        $this->settings->set('hazytheme::dark_mode', $request->input('hazytheme::dark_mode'));

        $this->alert->success('HazyTheme settings have been updated.')->flash();

        return redirect()->route('admin.settings.hazytheme');
    }
}

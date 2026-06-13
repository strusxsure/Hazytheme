<?php

namespace Pterodactyl\Http\ViewComposers;

use Illuminate\View\View;
use Pterodactyl\Services\Helpers\AssetHashService;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;

class AssetComposer
{
    /**
     * AssetComposer constructor.
     */
    public function __construct(
        private AssetHashService $assetHashService,
        private SettingsRepositoryInterface $settings
    ) {
    }

    /**
     * Provide access to the asset service in the views.
     */
    public function compose(View $view): void
    {
        $view->with('asset', $this->assetHashService);
        $view->with('siteConfiguration', [
            'name' => config('app.name') ?? 'Pterodactyl',
            'locale' => config('app.locale') ?? 'en',
            'recaptcha' => [
                'enabled' => config('recaptcha.enabled', false),
                'siteKey' => config('recaptcha.website_key') ?? '',
            ],
            'hazytheme' => [
                'primary_color' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
                'animation' => $this->settings->get('hazytheme::animation', 'true') === 'true',
                'sidebar_power' => $this->settings->get('hazytheme::sidebar_power', 'true') === 'true',
                'dark_mode' => $this->settings->get('hazytheme::dark_mode', 'true') === 'true',
            ],
        ]);
    }
}

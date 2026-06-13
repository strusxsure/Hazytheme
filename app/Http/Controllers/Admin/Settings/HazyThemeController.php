<?php
namespace Pterodactyl\Http\Controllers\Admin\Settings;
use Illuminate\View\View;
use Illuminate\Http\Request;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Contracts\Repository\SettingsRepositoryInterface;
class HazyThemeController extends Controller {
    public function __construct(private SettingsRepositoryInterface $settings) {}
    public function index(): View {
        return view('admin.settings.hazytheme', [
            'hazy_primary' => $this->settings->get('hazytheme::primary_color', '#6366f1'),
            'hazy_animation' => $this->settings->get('hazytheme::animation', 'true'),
        ]);
    }
    public function update(Request $request) {
        $this->settings->set('hazytheme::primary_color', $request->input('hazytheme::primary_color'));
        $this->settings->set('hazytheme::animation', $request->input('hazytheme::animation'));
        return redirect()->route('admin.settings.hazytheme');
    }
}

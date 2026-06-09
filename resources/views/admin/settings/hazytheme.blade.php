@extends('layouts.admin')
@include('partials/admin.settings.nav', ['activeTab' => 'hazytheme'])

@section('title')
    HazyTheme Settings
@endsection

@section('content-header')
    <h1>HazyTheme Settings<small>Configure your custom glassmorphism theme.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Settings</li>
        <li class="active">HazyTheme</li>
    </ol>
@endsection

@section('content')
    @yield('settings::nav')
    <div class="row">
        <div class="col-xs-12">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title">Theme Configuration</h3>
                </div>
                <form action="{{ route('admin.settings.hazytheme') }}" method="POST">
                    <div class="box-body">
                        <div class="row">
                            <div class="form-group col-md-4">
                                <label class="control-label">Primary Accent Color</label>
                                <div>
                                    <input type="color" class="form-control" name="hazytheme::primary_color" value="{{ old('hazytheme::primary_color', $hazy_primary) }}" />
                                    <p class="text-muted"><small>Choose the highlight color for buttons and sidebar icons.</small></p>
                                </div>
                            </div>
                            <div class="form-group col-md-4">
                                <label class="control-label">Animated Backgrounds</label>
                                <div>
                                    <select name="hazytheme::animation" class="form-control">
                                        <option value="true" @if($hazy_animation === 'true') selected @endif>Enabled</option>
                                        <option value="false" @if($hazy_animation === 'false') selected @endif>Disabled</option>
                                    </select>
                                    <p class="text-muted"><small>Enable or disable the bokeh animation behind the glass panels.</small></p>
                                </div>
                            </div>
                            <div class="form-group col-md-4">
                                <label class="control-label">Sidebar Power Buttons</label>
                                <div>
                                    <select name="hazytheme::sidebar_power" class="form-control">
                                        <option value="true" @if($hazy_sidebar_power === 'true') selected @endif>Enabled</option>
                                        <option value="false" @if($hazy_sidebar_power === 'false') selected @endif>Disabled</option>
                                    </select>
                                    <p class="text-muted"><small>Show Start/Stop/Restart buttons directly in the sidebar.</small></p>
                                </div>
                            </div>
                            <div class="form-group col-md-4">
                                <label class="control-label">Default Theme Mode</label>
                                <div>
                                    <select name="hazytheme::dark_mode" class="form-control">
                                        <option value="true" @if($hazy_dark_mode === 'true') selected @endif>Dark (Frosted)</option>
                                        <option value="false" @if($hazy_dark_mode === 'false') selected @endif>Light (Clear)</option>
                                    </select>
                                    <p class="text-muted"><small>Set the default appearance for the glass panels.</small></p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="box-footer">
                        {!! csrf_field() !!}
                        <button type="submit" class="btn btn-sm btn-primary pull-right">Save Theme Settings</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection

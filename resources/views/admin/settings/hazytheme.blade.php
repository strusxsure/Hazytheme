@extends('layouts.admin')
@include('partials/admin.settings.nav', ['activeTab' => 'hazytheme'])
@section('title') HazyTheme Settings @endsection
@section('content')
    <div class="row"><div class="col-xs-12"><div class="box"><div class="box-header with-border"><h3 class="box-title">Theme Configuration</h3></div>
        <form action="{{ route('admin.settings.hazytheme') }}" method="POST">
            <div class="box-body"><div class="row">
                <div class="form-group col-md-4"><label>Primary Color</label><input type="color" class="form-control" name="hazytheme::primary_color" value="{{ old('hazytheme::primary_color', $hazy_primary) }}" /></div>
                <div class="form-group col-md-4"><label>Animations</label><select name="hazytheme::animation" class="form-control"><option value="true">Enabled</option><option value="false">Disabled</option></select></div>
            </div></div>
            <div class="box-footer">{!! csrf_field() !!}<button type="submit" class="btn btn-primary pull-right">Save</button></div>
        </form>
    </div></div></div>
@endsection

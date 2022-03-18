<?php

use Illuminate\Support\Facades\Route;
use App\Http\Middleware\CorsMiddleware;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::options( '/knishio.oauth', [
    'middleware' => [ CorsMiddleware::class ],
    function () {
        return response( [ 'status' => 'success' ] );
    }
] );

Route::post( '/knishio.oauth', [
    'middleware' => [ CorsMiddleware::class ],
    'as' => 'knishio_oauth',
    'uses' => 'TwitterController@token',
] );

Route::get('/', function () {

    $peerNode = new \WishKnish\KnishIO\Helpers\PeerNode;
    $peerNode->clearDB();
    dd( 'Cleared' );

    return view('index');
});

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Contracts\Container\BindingResolutionException;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * Class CorsMiddleware
 * @package WishKnish\KnishIO\GraphQL\Middleware
 */
class CorsMiddleware {
    /**
     * @var string[]
     */
    protected array $headers = [
        'Origin',
        'Accept',
        'Content-Type',
        'Authorization',
        'X-Auth-Token',
        'X-Requested-With',
        'Access-Control-Allow-Headers',
        'Access-Control-Request-Method',
        'Access-Control-Request-Headers',
        'Access-Control-Allow-Origin',
        'Sec-Fetch-Mode',
        'Sec-Fetch-Site',
        'Sec-Fetch-Dest',
        'User-Agent',
    ];

    /**
     * @var string[]
     */
    protected array $methods = [
        'POST',
        'GET',
        'OPTIONS',
        'PUT',
        'DELETE'
    ];

    /**
     * Handle an incoming request.
     *
     * @param Request $request
     * @param Closure $next
     *
     * @return mixed
     * @throws BindingResolutionException
     */
    public function handle ( Request $request, Closure $next ) {

        $headers = [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => implode( ', ', $this->methods ),
            'Access-Control-Allow-Credentials' => 'true',
            'Access-Control-Max-Age' => '86400',
            'Access-Control-Allow-Headers' => implode( ', ', $this->headers )
        ];

        if ( $request->isMethod( 'OPTIONS' ) ) {
            return response()->json( '{"method":"OPTIONS"}', 200, $headers );
        }

        /** @var Response $response */
        $response = $next( $request );

        return $response->withHeaders( $headers );
    }
}

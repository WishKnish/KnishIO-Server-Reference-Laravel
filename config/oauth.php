<?php

use App\Helpers\OAuthTwitter;
use App\Helpers\OAuthLinkedin;

return [
    'key' => [
        'twitter' => [
            'key' => env( 'TWITTER_API_KEY' ),
            'secret' => env( 'TWITTER_API_SECRET' ),
        ],
        'linkedin' => [
            'key' => env( 'LINKEDIN_CLIENT_ID' ),
            'secret' => env( 'LINKEDIN_CLIENT_SECRET' ),
        ]
    ],
    'driver' => [
        'twitter' => [
            'class' => OAuthTwitter::class,
            'method' => [
                'getAuthUrl',
                'getUserData',
            ],
        ],
        'linkedin' => [
            'class' => OAuthLinkedin::class,
            'method' => [
                'getAuthUrl',
                'getUser',
            ],
        ],
    ],

];

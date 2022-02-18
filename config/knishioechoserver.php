<?php
return [

    'auth_host' => \env( 'LARAVEL_ECHO_SERVER_AUTH_HOST', '127.0.0.1' ),
    'auth_endpoint' => \env( 'LARAVEL_ECHO_SERVER_AUTH_ENDPOINT', '/graphql/subscriptions/auth' ),
    'clients' => [],
    'database' => \env( 'LARAVEL_ECHO_SERVER_DATABASE', 'redis' ),
    'database_config' => [

        'redis' => [

            'port' => \env( 'LARAVEL_ECHO_SERVER_REDIS_PORT', '6379' ),
            'host' => \env( 'LARAVEL_ECHO_SERVER_REDIS_HOST', '127.0.0.1' ),
            'options' => [

                'password' => \env( 'LARAVEL_ECHO_SERVER_REDIS_PASSWORD', null ),

            ],

        ],

        'sqlite' => [

            'database_path' => \env( 'LARAVEL_ECHO_SERVER_SQLITE_PATH', '/database/laravel-echo-server.sqlite' ),

        ],

        'publish_presence' => \env( 'LARAVEL_ECHO_SERVER_PUBLISH_PRESENCE', true ),

    ],

    'dev_mode' => \env( 'LARAVEL_ECHO_SERVER_DEV_MODE', 'true' ),
    'host' => \env( 'LARAVEL_ECHO_SERVER_HOST', '0.0.0.0' ),
    'port' => \env( 'LARAVEL_ECHO_SERVER_PORT', '3000' ),
    'protocol' => \env( 'LARAVEL_ECHO_SERVER_PROTOCOL', 'http' ),
    'socketio' => [],
    'secure_options' => \env( 'LARAVEL_ECHO_SERVER_SECURE_OPTIONS', 67108864 ),
    'ssl_cert_path' => \env( 'LARAVEL_ECHO_SERVER_SSL_CERT_PATH', '' ),
    'ssl_key_path' => \env( 'LARAVEL_ECHO_SERVER_SSL_KEY_PATH', '' ),
    'ssl_cert_chain_path' => \env( 'LARAVEL_ECHO_SERVER_SSL_CERT_CHAIN_PATH', '' ),
    'ssl_passphrase' => \env( 'LARAVEL_ECHO_SERVER_SSL_PASSPHRASE', '' ),

    'subscribers' => [

        'http' => \env( 'LARAVEL_ECHO_SERVER_SUBSCRIBERS_HTTP', true ),
        'redis' => \env( 'LARAVEL_ECHO_SERVER_SUBSCRIBERS_REDIS', true ),

    ],

    'api_origin_allow' => [

        'allow_cors' => \env( 'LARAVEL_ECHO_SERVER_API_ORIGIN_ALLOW_CORS', true ),
        'allow_origin' => \env( 'LARAVEL_ECHO_SERVER_AUTH_HOST', '127.0.0.1' ) . ':' . \env( 'LARAVEL_ECHO_SERVER_AUTH_PORT', '80' ),
        'allow_methods' => \env( 'LARAVEL_ECHO_SERVER_API_ORIGIN_ALLOW_METHODS', 'POST' ),
        'allow_headers' => \env( 'LARAVEL_ECHO_SERVER_API_ORIGIN_ALLOW_HEADERS', 'Origin, Content-Type, X-Auth-Token, X-Requested-With, Accept, Authorization, X-CSRF-TOKEN, X-Socket-Id' ),

    ],

];

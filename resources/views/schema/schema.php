<?= view('_parts/header', [ 'pageTitle' => 'Knish.IO Schema' ]) ?>
    <link rel="stylesheet" href="/assets/css/schema.css" />
    <div id="app">
        <h1>KnishIO schema</h1>

        <table class="schema-fields">
            <tr>
                <td>Property</td>
                <td>Description</td>
            </tr>
            <?php foreach( $jsonldTypes as $fieldObject ): ?>
                <tr>
                    <td><a href="<?= $fieldObject->url() ?>"><?= $fieldObject->id() ?></td>
                    <td><?= $fieldObject->description() ?></td>
                </tr>
            <?php endforeach; ?>
        </table>

    </div>

<?= view('_parts/footer') ?>

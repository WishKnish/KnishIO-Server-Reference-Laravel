<?= view('_parts/header', [ 'pageTitle' => 'Knish.IO Type ' . $jsonldType->id() ]) ?>

<div id="app">
    <h1>KnishIO <?= $jsonldType->id() ?></h1>

    <h3><?= $jsonldType->description() ?></h3><br />

    <?php if( $jsonldType->fields() ): ?>
        <?= view( 'schema/_parts/type_list', [ 'jsonldTypes' => $jsonldType->fields() ] ) ?>
    <?php endif; ?>
</div>

<?= view('_parts/footer') ?>

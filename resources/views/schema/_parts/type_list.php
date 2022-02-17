<table class="schema-fields">
    <tr>
        <td>Property</td>
        <td>Expected Type</td>
        <td>Description</td>
    </tr>
    <?php foreach( $jsonldTypes as $fieldObject ): ?>
        <tr>
            <th><div><a href="<?= $fieldObject->url() ?>"><?= $fieldObject->id() ?></div></th>
            <td>
                <?php foreach( $fieldObject->types() as $expectedType ): ?>
                    <div><?= $expectedType ?></div>
                <?php endforeach; ?>
            </td>
            <td><?= $fieldObject->description() ?></td>
        </tr>
    <?php endforeach; ?>
</table>

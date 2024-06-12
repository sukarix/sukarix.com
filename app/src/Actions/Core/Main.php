<?php

declare(strict_types=1);

namespace Actions\Core;

use Sukarix\Actions\WebAction;

/**
 * Index Action Class.
 */
class Main extends WebAction
{
    /**
     * @param \Base $f3
     * @param array $params
     */
    public function execute($f3, $params): void
    {
        $this->render();
    }
}

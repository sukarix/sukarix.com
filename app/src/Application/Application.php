<?php

declare(strict_types=1);

namespace Application;

use Sukarix\Application\Bootstrap;

class Application extends Bootstrap
{
    protected function loadAppSetting(): void
    {
        $this->session->set('locale', 'en-GB');
        parent::loadAppSetting();
    }
}

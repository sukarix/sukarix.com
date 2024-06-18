<?php

declare(strict_types=1);

namespace Core;

use Sukarix\TestScenario;

/**
 * @coversNothing
 */
final class ConfigurationTest extends TestScenario
{
    protected $group = 'Framework & Server Configuration';

    /**
     * @param $f3 \Base
     *
     * @return array
     */
    public function testDefaultConfiguration($f3)
    {
        $test = $this->newTest();
        $test->expect('UTC' === date_default_timezone_get(), 'Timezone set to UTC');
        $test->expect('UTF-8' === \ini_get('default_charset'), 'Default charset is UTF-8');
        $test->expect('../logs/' === $f3->get('LOGS'), 'Logs folder correctly configured to "logs"');
        $test->expect('../tmp/' === $f3->get('TEMP'), 'Cache folder correctly configured to "tmp/cache/"');
        $test->expect(0 === mb_strpos($f3->get('UI'), 'templates/;../public/;'), 'Templates folder correctly configured to "templates" and "public"');
        $test->expect('en-GB' === $f3->get('FALLBACK'), 'Fallback language set to en-GB');
        $test->expect('pgsql' === $f3->get('db.driver'), 'Using PostgresSQL database for session storage');
        $test->expect($f3->get('application.logfile') === '../logs/' . (\PHP_SAPI !== 'cli' ? 'app' : 'cli') . '-' . date('Y-m-d') . '.log', 'Log file name set to daily rotation app-' . date('Y-m-d') . '.log');

        return $test->results();
    }
}

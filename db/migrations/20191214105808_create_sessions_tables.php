<?php

declare(strict_types=1);

use Phinx\Migration\AbstractMigration;

class CreateSessionsTables extends AbstractMigration
{
    public function up(): void
    {
        $table = $this->table('users_sessions');
        $table->addColumn('session_id', 'string', ['limit' => 256, 'null' => false])
            ->addColumn('data', 'text', ['null' => true])
            ->addColumn('ip', 'string', ['limit' => 56, 'null' => true])
            ->addColumn('agent', 'string', ['limit' => 512, 'null' => true])
            ->addColumn('stamp', 'integer', ['null' => true])
            ->save()
        ;
    }

    public function down(): void
    {
        $this->table('users_sessions')->drop()->save();
    }
}

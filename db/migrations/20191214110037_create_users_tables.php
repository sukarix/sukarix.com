<?php

declare(strict_types=1);

/*
 * Created by 207 Technology Group Inc. & RIADVICE SUARL
 * Copyright 2019-2024 | 207 Technology Group Inc. & RIADVICE SUARL ( c )
 * All rights reserved. You may not use, distribute or modify
 * this code under its source or binary form without the express
 * authorization of 207 Technology Group Inc. & RIADVICE SUARL. Contact : sdame@207me.com, devops@riadvice.tn
 */

use Phinx\Migration\AbstractMigration;

class CreateUsersTables extends AbstractMigration
{
    public function up(): void
    {
        $table = $this->table('users');
        $table->addColumn('email', 'string', ['limit' => 256, 'null' => false])
            ->addColumn('username', 'string', ['limit' => 32, 'null' => false])
            ->addColumn('role', 'string', ['limit' => 32, 'default' => 'admin', 'null' => false])
            ->addColumn('password', 'string', ['limit' => 256, 'null' => false])
            ->addColumn('status', 'string', ['limit' => 32, 'default' => 'inactive', 'null' => false])
            ->addColumn('last_login', 'datetime', ['default' => '0001-01-01 00:00:00', 'timezone' => true])
            ->addColumn('created_on', 'datetime', ['default' => '0001-01-01 00:00:00', 'timezone' => true])
            ->addColumn('updated_on', 'datetime', ['default' => '0001-01-01 00:00:00', 'timezone' => true])
            ->addIndex('username', ['unique' => true, 'name' => 'idx_users_username'])
            ->addIndex('email', ['unique' => true, 'name' => 'idx_users_email'])
            ->save()
        ;
    }

    public function down(): void
    {
        $this->table('users')->drop()->save();
    }
}

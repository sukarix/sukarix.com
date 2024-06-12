<?php

declare(strict_types=1);

use Phinx\Migration\AbstractMigration;

class AddDefaultAdminRecord extends AbstractMigration
{
    public function up(): void
    {
        // Add super admin user
        $userTable = $this->table('users');

        $userData = [
            [
                'email'      => 'admin@email.com',
                'username'   => 'admin',
                'role'       => 'admin',
                'password'   => '$2y$10$36d51ca3b8acdf6cdbda9uJ4TizvdKg.slgIFo/6uy4Wrm5DONCiG',
                'status'     => 'active',
                'created_on' => date('Y-m-d H:i:s'),
            ],
        ];

        $userTable->insert($userData)->save();
    }

    public function down(): void
    {
        $userTable = $this->table('users');
        $userTable->getAdapter()->execute("DELETE from users where email='admin@email.com'");
    }
}

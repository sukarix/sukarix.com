<?php

declare(strict_types=1);

return [
    'i18n' => [
        'label' => [
            'core' => [
                'email'                 => 'Email',
                'password'              => 'Password',
                'password_hint'         => 'Password (8 characters at minimum)',
                'first_name'            => 'First Name',
                'last_name'             => 'Last Name',
                'back'                  => 'Back',
                'submit'                => 'Submit',
                'confirm'               => 'Approve',
                'cancel'                => 'Cancel',
                'logo'                  => 'Logo',
                'first'                 => 'First',
                'last'                  => 'Last',
                'actions'               => 'Actions',
                'send_email'            => 'Send email',
                'password_confirmation' => 'confirm password',
                'save_password'         => 'save password',
                'add'                   => 'Add',
                'edit'                  => 'Edit',
                'save'                  => 'Save',
                'view_more'             => 'View More...',
                'register'              => 'Register',
                'id'                    => 'ID',
                'search'                => 'Search...',
                'sending'               => 'Sending...',
                'at'                    => 'at',
            ],

            'menu' => [
                'users' => 'Users',
            ],

            'user' => [
                'users'            => 'Users',
                'user'             => 'User',
                'email'            => 'Email',
                'role'             => 'Role',
                'status'           => 'Status',
                'first_name'       => 'First name',
                'last_name'        => 'Last name',
                'edit_user'        => 'Edit user',
                'new_user'         => 'New user',
                'add_user'         => 'Add user',
                'my_profile'       => 'My profile',
                'new_password'     => 'New Password',
                'reset_password'   => 'Reset password',
                'current_password' => 'Current Password',
                'confirm_password' => 'Confirm Password',
                'change_password'  => 'Change my password',
            ],
        ],
        'message' => [
            'core' => [
                'login'               => 'Log me in',
                'logout'              => 'Logout',
                'delete_confirm'      => 'Do you want to continue ?',
                'yes'                 => 'Yes',
                'no'                  => 'No',
                'cancel'              => 'Cancel',
                'all_rights_reserved' => 'All rights reserved',
                'copyright'           => 'Copyright',
                'record_updated'      => 'Record updated',
            ],

            'user' => [
                'login_success'           => 'Welcome back {0}!',
                'add_success'             => 'User successfully added',
                'edit_user'               => 'Edit user',
                'delete_user'             => 'Delete user',
                'edit_success'            => 'User {0} successfully edited',
                'profile_edit_success'    => 'Profile successfully edited',
                'delete_success'          => 'User {0} successfully deleted',
                'change_password_success' => 'Password successfully changed',
            ],
        ],
        'error' => [
            'core' => [
                'server_error' => 'Unexpected server error',
                'empty'        => 'This field is required',
            ],

            'login' => [
                'email'         => 'Invalid email address',
                'password'      => 'Invalid password',
                'password_size' => 'Password length must be 8 characters at least',
            ],
        ],
        'list' => [
            // From https://github.com/umpirsky/country-list/tree/master/country/icu
            'countries' => [],

            'locales' => [
                'en-GB' => 'English',
            ],

            'roles' => [
                'admin'    => 'Administrator',
                'customer' => 'Customer',
            ],

            'statuses' => [
                'inactive' => 'Inactive',
                'active'   => 'Active',
            ],

            'statuses_tags' => [
                'Y' => 'Active',
                'N' => 'Passive',
            ],

            'days' => [
                'monday'    => 'Monday',
                'tuesday'   => 'Tuesday',
                'wednesday' => 'Wednesday',
                'thursday'  => 'Thursday',
                'friday'    => 'Friday',
                'saturday'  => 'Saturday',
                'sunday'    => 'Sunday',
            ],
            'months' => [
                'january'   => 'January',
                'february'  => 'February',
                'march'     => 'March',
                'april'     => 'April',
                'may'       => 'May',
                'june'      => 'June',
                'july'      => 'July',
                'august'    => 'August',
                'september' => 'September',
                'october'   => 'October',
                'november'  => 'November',
                'december'  => 'December',
            ],
        ],
    ],
];

use t::devel::share;


my ($wait, $cron);


ok !path('config/var')->exists,             'no config yet, creating…';
path('config/var')->spew_utf8('val');
not_install(release('add_config var val'));
not_install(release('add_config var'));
not_install(release('add_config var -', 'val'));
ok path('config/var')->exists,              'install failed, removing…';
path('config/var')->remove;

install(release('add_config var val'));
ok path('config/var')->exists,              'config added';
is path('config/var')->slurp_utf8, 'val',   '… with value';
install(BASEVER);
ok !path('config/var')->exists,             'config removed';

install(release('add_config var'));
ok path('config/var')->exists,              'config added';
is -s 'config/var', 0,                      '… without value';
path('config/var')->spew_utf8('val');
install(BASEVER);
ok !path('config/var')->exists,             'modified config removed';

install(release('add_config var -','  line1','','  line3'));
ok path('config/var')->exists,              'config added';
$wait = "line1\n\nline3\n";
is path('config/var')->slurp_utf8, $wait,   '… with multiline value';
path('config/var')->remove;
ok !path('config/var')->exists,             'config removed';
install(BASEVER);

install(release('add_config var/var2/var3 val'));
ok path('config/var/var2/var3')->exists,    'config added, parent dirs created';
is path('config/var/var2/var3')->slurp_utf8, 'val',   '… with value';
install(BASEVER);
ok !path('config/var')->exists,             'config removed, empty parent dirs too';

unlike +`crontab -l`, qr/CRONTEST/,         'cron not set yet';
install(release('add_config crontab/crontest "* * * * * echo CRONTEST >/dev/null"'));
like +`crontab -l`, qr/CRONTEST/,           'cron is set';
install(BASEVER);
unlike +`crontab -l`, qr/CRONTEST/,         'cron not set after downgrade';


done_testing();

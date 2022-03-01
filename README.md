# Laravel Octane setup for Homestead using swoole

Quick setup to run Laravel applications using octane on Homestead.

This implementation works for PHP 8.0

Download this repository and copy each file to it's correspondent folder in Homestead:

```bash
cp laravel-octane.sh /PATH-TO/Homestead/scripts/features/site-types/
cp swoole.sh /PATH-TO/Homestead/scripts/features/
```

Then enable swoole on your `Homestead.yaml`

```
features:
    - swoole: true
```

Specify the site-type in your site's configuration block in the `Homestead.yaml` file

```
sites: 
   - map: my-project.test
      to: /home/vagrant/Code/path-to-project/public
      php: "8.0"
      type: "laravel-octane"
```

Finally run `homestead provision`

Once the proces finishes login into homestead using `vagrant ssh` and run `php artisan octane:start` from the project's root foolder.

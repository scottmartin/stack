# Ubuntu 12.04 Stack Installer

This is a simple shell script I wrote to quickly set up staging and production servers for my [Ruby on Rails](http://rubyonrails.org) applications. I looked at both [Chef](http://wiki.opscode.com/display/chef/Home) and [Sprinkle](https://github.com/crafterm/sprinkle) before deciding to go with a pure [Bash](http://en.wikipedia.org/wiki/Bash_(Unix_shell)) script. Chef appeared to be too complicated for my simple needs and although Sprinkle looked like it would've been perfect, I ran into issues getting it to work.

## This Script Will

1. Update system packages
2. Restrict SSH to only use authentication keys and disable root login
3. Setup firewall rules only allowing pings and traffic to ports 22, 80, and 443
4. Install [Fail2Ban](http://www.fail2ban.org)
5. Install [curl](http://curl.haxx.se) and [Git](http://git-scm.com)
6. (Optional) Install and configure [New Relic Server Monitor](http://newrelic.com/lp/server-monitoring)
7. Install and configure [NGINX](http://nginx.com) from its official repository
8. (Your Choice) Install and configure [PostgreSQL](http://postgresql.org) from its official repository, or [MySQL](http://mysql.com)
9. (Optional) Install and configure [Postfix](http://www.postfix.org)
10. Install and configure [rbenv](https://github.com/sstephenson/rbenv) along with all of the packages required to compile [Ruby](http://www.ruby-lang.org)

## A New User

This script uses the `sudo` command heavily. If you are still running under **root**, you are encouraged to login to your server and run the following;

```bash
adduser example_user
usermod -a -G sudo example_user
```

You can now logout and use this user from now on.

## SSH Authentication Key

If you don't already have an SSH key on your local machine you can set one up by running the following:

```bash
ssh-keygen -t rsa -C "your_email@example.com"
```

Once the key has been generated, you can copy it to your server:

```bash
scp ~/.ssh/id_rsa.pub example_user@10.0.0.100:~/
ssh example_user@10.0.0.100
mkdir .ssh
mv id_rsa.pub .ssh/authorized_keys
chown -R example_user:example_user .ssh
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
```

This process can be much easier if you use the `ssh-copy-id` utility. If you're local machine is a distro of Linux/Unix you may already have it. If you're on a Mac you can get it using [Homebrew](http://mxcl.github.com/homebrew).

Once you have it, copying your key is as easy as:

```bash
ssh-copy-id example_user@10.0.0.100
```

## Usage

Once your server is up and running, your basic network settings are set, and you have a new user with an SSH key copied over, you're ready to run the script. You need the whole stack directory to be on your server, preferably in your home directory.

You could download it to your local machine and `rsync` it to your server:

```bash
cd path/to/stack
rsync -zvr . example_user@10.0.0.100:~/stack
```

Or from the server, if you have git installed, you could just clone it:

```bash
git clone git://github.com/scottmartin/stack.git ~/stack
```

Finally, you just run the script from your server, answer the questions, and sit back and relax:

```bash
./stack/install.sh
```

## License

Copyright © 2013 Scott Martin. Licensed under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

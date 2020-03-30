# Syspass

Simple client of sysPass API


## Installation

```ruby
gem 'syspass-client'
```
And execute:
    $ bundle

Or: 
    $ gem install syspass-client

## Usage

```ruby
require 'syspass'

sp = Syspass.new('http://localhost/syspass/api.php', 
    authToken: 'syspass-auth-token', 
    tokenPass: 'syspass-token-pass')

sp.account.search
sp.account.view(id: 1)
sp.account.viewPass(id: 1)
```

Use sysPass API doc: https://syspass-doc.readthedocs.io/en/3.0/application/api.html
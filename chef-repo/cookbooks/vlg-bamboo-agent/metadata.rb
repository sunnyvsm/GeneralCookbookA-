name             'vlg-bamboo-agent'
maintainer       'Videology Group, Inc.'
maintainer_email 'gio@videologygroup.com'
license          'All rights reserved'
description      'Installs/Configures vlg-bamboo-agent'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.27'
depends		 'vlg-base'
depends		 'vlg-all-in-one'
depends    'vlg-ssh-key'
depends		 'vlg-haproxy'
depends		 'vlg-deploy'

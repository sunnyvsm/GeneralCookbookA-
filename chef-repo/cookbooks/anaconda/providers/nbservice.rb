def whyrun_supported?
  true
end

def cmd_ipython
  "#{node.anaconda.install_root}/#{node.anaconda.version}/bin/ipython"
end

def is_installed?(package_name)
  `"#{cmd_conda}" list`.include?(package_name)
end

def log_opts(node)
  if node.anaconda.install_log
    "2>&1 >#{node.anaconda.install_log}"
  else
    ''
  end
end

action :create do
  r = new_resource

  directory r.install_dir do
    owner r.user
    group r.group
    recursive true
  end

  ipython_dir = "#{r.install_dir}/.ipython"
  directory ipython_dir do
    owner r.user
    group r.group
    recursive true
  end

  execute 'Create_Profile_nbserver' do
    cwd #{ipython_dir}
    user r.user
    command "#{node.anaconda.install_root}/#{node.anaconda.version}/bin/python #{node.anaconda.install_root}/#{node.anaconda.version}/bin/ipython profile create #{node['anaconda']['profile']} --ipython-dir=#{ipython_dir}"
    action :run
  end

  template "#{ipython_dir}/profile_#{node['anaconda']['profile']}/ipython_notebook_config.py" do
    source 'ipython_notebook_config.py.erb'
    owner r.user
    group r.group
    mode '0644'
    variables(:password => node['anaconda']['password'])
  end

  pythonpath = r.pythonpath || [ ]
  pythonstartup = r.pythonstartup || nil
  files_to_source = r.files_to_source || [ ]
  service_action = r.service_action || [ :enable, :start ]

  ip = r.ip || '*'
  port = r.port || '8888'
  profile = r.profile || 'nbserver'

  template_cookbook = r.template_cookbook || 'anaconda'
  run_template_name = r.run_template_name || 'ipython-notebook'
  run_template_opts = r.run_template_opts || {
    :user => r.user,
    :cmd_ipython => cmd_ipython(),
    :notebook_dir => r.install_dir,
    :ipython_dir => ipython_dir,
    :ip => ip,
    :port => port,
    :pythonpath => pythonpath,
    :pythonstartup => pythonstartup,
    :files_to_source => files_to_source,
    :profile => profile,
  }

  runit_service "ipython-notebook-#{r.name}" do
    options(run_template_opts)
    default_logger true
    run_template_name run_template_name
    cookbook template_cookbook
    action service_action
  end
end

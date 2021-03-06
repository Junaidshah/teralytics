#
# Cookbook Name:: tar
# Provider:: package
#
# Author:: Nathan L Smith (<nathan@cramerdev.com>)
#
# Copyright:: 2011, Cramer Development, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

def whyrun_supported?
  true
end

action :install do
  r = new_resource
  basename = r.archive_name || ::File.basename(r.name)
  dirname = basename.chomp('.tar.gz') # Assuming .tar.gz
  src_dir = r.source_directory

  remote_file basename do
    source r.name
    path "#{src_dir}/#{basename}"
    backup false
    headers r.headers unless r.headers.nil?
    use_etag r.use_etag
    use_last_modified r.use_last_modified
    atomic_update r.atomic_update
    force_unlink r.force_unlink
    manage_symlink_source r.manage_symlink_source
    action :create_if_missing
  end

  execute "extract #{basename}" do
    command "tar xfz #{basename}"
    cwd src_dir
    creates "#{src_dir}/#{dirname}"
  end

  execute "compile & install #{dirname}" do
    flags = [r.prefix ? "--prefix=#{r.prefix}" : nil, *r.configure_flags].compact.join(' ')
    command "./configure --quiet #{flags} && make --quiet && make --quiet install"
    cwd "#{src_dir}/#{dirname}"
    creates r.creates
  end
end

# Main class to allow passing required swapfiles as hashes
#
# @example Will create one swapfile in /mnt/swap using the defaults.
#   class { '::swap_file':
#     'files' => {
#       'resource_name' => {
#         ensure   => present,
#         swapfile => '/mnt/swap',
#       },
#     },
#   }
#
# @example Will create two swapfile with the given parameters
#   class { 'swap_file':
#     'files' => {
#       'swap1' => {
#         ensure       => present,
#         swapfile     => '/mnt/swap.1',
#         swapfilesize => '1 GB',
#       },
#       'swap2' => {
#         ensure       => present,
#         swapfile     => '/mnt/swap.2',
#         swapfilesize => '2 GB',
#         cmd          => 'fallocate',
#       },
#     },
#   }
#
# @example Will merge all found instances of swap_file::files found in hiera and create resources for these.
#   class { '::swap_file':
#     files_hiera_merge: true,
#   }
#
# @param [Hash] files Hash of swap files to ensure with swap_file::files
# @param [Boolean] files_hiera_merge Boolean to merge all found instances of swap_file::files in Hiera.
#   This can be used to specify swap files at different levels an have
#   them all included in the catalog.
#
# @author - Peter Souter
#
class swap_file (
  Hash $files                                              = {},
  Variant[Boolean,Enum['true','false']] $files_hiera_merge = false,
) {
  # variable handling
  if $files_hiera_merge =~ Boolean {
    $files_hiera_merge_bool = $files_hiera_merge
  } else {
    $files_hiera_merge_bool = str2bool($files_hiera_merge)
  }

  # functionality
  if $files_hiera_merge_bool == true {
    $files_real = lookup('swap_file::files', Hash, 'deep', {})
  } else {
    $files_real = $files
  }
  if $files_real != undef {
    create_resources('swap_file::files', $files_real)
  }
}
